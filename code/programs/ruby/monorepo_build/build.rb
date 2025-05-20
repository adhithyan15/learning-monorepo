require 'open3'
require 'set'
require 'pathname'

require_relative 'lib/get_context'
require_relative 'lib/find_vswhere'

# --- Configuration ---
BUILD_FILE_PATTERN = /^BUILD(?:_windows|_mac_and_linux|_mac|_linux)?$/
DIRS_FILE_NAME = 'DIRS'
BUILD_COMMENT_CHAR = '#'

# ==================================================
# MSVC Environment Setup Code (for Windows)
# ==================================================

def find_vcvarsall(context, vs_version = nil)
  vswhere_exe = find_vswhere(context)

  cmd = [
    vswhere_exe,
    '-property', 'installationPath',
    '-requires', 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
    '-nologo',
    '-sort'
  ]
  cmd.push('-latest') if vs_version.nil?
  cmd.push('-version', vs_version) if vs_version

  stdout, stderr, status = Open3.capture3(*cmd)

  unless status.success? && !stdout.empty?
    raise "vswhere failed to find Visual Studio installation.\nStderr: #{stderr}\nStdout: #{stdout}"
  end

  install_path = Pathname.new(stdout.lines.first.strip)
  vcvarsall = install_path / 'VC' / 'Auxiliary' / 'Build' / 'vcvarsall.bat'

  unless vcvarsall.exist?
    raise "Found Visual Studio at #{install_path}, but vcvarsall.bat was not found at expected location: #{vcvarsall}"
  end

  vcvarsall.to_s
end

def parse_env(set_output_lines)
  env_hash = {}
  set_output_lines.each do |line|
    line.strip!
    parts = line.split('=', 2)
    next unless parts.length == 2 && !parts[0].empty?

    env_hash[parts[0]] = parts[1]
  end
  env_hash
end

def is_path_variable?(name)
  name.match?(/^(PATH|LIB|INCLUDE|LIBPATH)$/i)
end

def filter_path_value(path_string)
  Set.new(path_string.split(';').reject(&:empty?)).to_a.join(';')
end

def setup_msvc_env(context, arch: 'x64', sdk: nil, toolset: nil, uwp: false, spectre: false, vs_version: nil)
  begin
    vcvarsall_path = find_vcvarsall(context, vs_version)
    context.logger.info("MSVC: Found vcvarsall.bat at: #{vcvarsall_path}")
  rescue => e
    context.logger.error("MSVC: Failed to find vcvarsall.bat: #{e.message}")
    raise
  end

  vcvars_args = [arch]
  vcvars_args << 'uwp' if uwp
  vcvars_args << sdk if sdk
  vcvars_args << "-vcvars_ver=#{toolset}" if toolset
  vcvars_args << '-vcvars_spectre_libs=spectre' if spectre

  vcvars_command = %("#{vcvarsall_path}" #{vcvars_args.join(' ')})
  context.logger.info("MSVC: vcvars command line: #{vcvars_command}")

  full_command = "set && cls && #{vcvars_command} && cls && set"
  context.logger.debug("MSVC: Executing: #{full_command}")
  output, status = Open3.capture2e("cmd /c \"#{full_command}\"")

  unless status.success?
    context.logger.warn("MSVC: Environment capture command execution might have failed. Status: #{status.exitstatus}")
    context.logger.warn("MSVC: Output was:\n#{output}")
    raise "Failed to execute MSVC environment capture command. Status: #{status.exitstatus}" if status.exitstatus != 0
  end

  output_parts = output.split("\f")
  unless output_parts.length == 3
    context.logger.error('MSVC: Unexpected output format when splitting by form feed (cls).')
    context.logger.error("MSVC: Expected 3 parts, got #{output_parts.length}.")
    context.logger.error("MSVC: Full output:\n#{output}")
    raise 'Failed to parse MSVC environment capture output.'
  end

  before_env = parse_env(output_parts[0].lines)
  vcvars_out_lines = output_parts[1].lines
  after_env = parse_env(output_parts[2].lines)

  error_messages = vcvars_out_lines.map(&:strip).select do |line|
    line.match?(/^\[ERROR.*\]/i) && !line.match?(/Error in script usage. The correct usage is:/)
  end

  unless error_messages.empty?
    context.logger.error('MSVC: vcvarsall.bat reported errors:')
    error_messages.each { |err| context.logger.error("- #{err}") }
    raise 'vcvarsall.bat failed with errors. See log for details.'
  end

  context.logger.info('MSVC: Processing environment variables...')
  changed_vars = 0
  new_vars = 0

  after_env.each do |key, new_value|
    old_value = before_env[key]
    next if new_value == old_value

    old_value.nil? ? new_vars += 1 : changed_vars += 1
    ENV[key] = is_path_variable?(key) ? filter_path_value(new_value) : new_value
  end

  context.logger.info('MSVC: Environment configured successfully.')
  context.logger.info("MSVC: #{new_vars} new variables, #{changed_vars} changed variables applied to current process environment.")
end

# ==================================================
# End of MSVC Environment Setup Code
# ==================================================

# --- Helper Functions ---

def execute_command(context, command, current_working_directory)
  context.logger.info("CMD: In '#{current_working_directory}': #{command}")
  stdout_str, stderr_str, status = Open3.capture3(ENV, command, chdir: current_working_directory)

  context.logger.info(stdout_str.strip) unless stdout_str.strip.empty?

  unless status.success?
    context.logger.error("Command failed! (Exit Status: #{status.exitstatus})")
    context.logger.error(stderr_str.strip) unless stderr_str.strip.empty?
    context.exit_handler.exit_with_code(status.exitstatus)
  end
rescue => e
  context.logger.error("Failed to execute command '#{command}' in '#{current_working_directory}': #{e.message}")
  context.exit_handler.exit_with_code(1)
end

def check_os_match(build_file_path)
  filename = File.basename(build_file_path)
  is_windows = RUBY_PLATFORM.match?(/mingw|mswin/i)
  is_mac = RUBY_PLATFORM.include?('darwin')
  is_linux = !is_windows && !is_mac && RUBY_PLATFORM.include?('linux')

  case filename
  when /_windows$/
    is_windows
  when /_mac_and_linux$/
    is_mac || is_linux
  when /_mac$/
    is_mac
  when /_linux$/
    is_linux
  else
    true
  end
end

def process_build_file(context, build_file_path)
  absolute_path = File.absolute_path(build_file_path)

  unless check_os_match(absolute_path)
    context.logger.info("Skipping BUILD file #{File.basename(absolute_path)} in #{File.dirname(absolute_path)} due to OS mismatch.")
    return
  end

  context.logger.info("Processing BUILD file: #{absolute_path}")
  current_directory = File.dirname(absolute_path)

  begin
    File.readlines(absolute_path).each do |line|
      command = line.strip
      next if command.empty? || command.start_with?(BUILD_COMMENT_CHAR)
      execute_command(context, command, current_directory)
    end
  rescue Errno::ENOENT
    context.logger.error("Build file not found: #{absolute_path}")
    context.exit_handler.exit_with_code(1)
  rescue => e
    context.logger.error("Error reading build file #{absolute_path}: #{e.message}")
    context.exit_handler.exit_with_code(1)
  end
end

def process_dirs_file(context, dirs_file_path)
  absolute_path = File.absolute_path(dirs_file_path)

  if context.file_processing_history.already_processed?(absolute_path)
    context.logger.warn("Already processed DIRS file #{absolute_path}, skipping to prevent infinite loop.")
    return
  end
  context.file_processing_history.mark_processed(absolute_path)

  context.logger.info("Processing DIRS file: #{absolute_path}")
  current_directory = File.dirname(dirs_file_path)

  begin
    File.readlines(dirs_file_path).each do |next_dir_rel_path|
      stripped_path = next_dir_rel_path.strip
      next if stripped_path.empty? || stripped_path.start_with?(BUILD_COMMENT_CHAR)

      full_next_dir_path = File.absolute_path(File.join(current_directory, stripped_path))
      unless Dir.exist?(full_next_dir_path)
        context.logger.warn("Directory '#{full_next_dir_path}' listed in #{absolute_path} not found. Skipping.")
        next
      end

      Dir.foreach(full_next_dir_path) do |entry|
        next if entry == '.' || entry == '..'
        full_entry_path = File.join(full_next_dir_path, entry)

        if File.file?(full_entry_path)
          filename = File.basename(full_entry_path)
          if filename == DIRS_FILE_NAME
            process_dirs_file(context, full_entry_path)
          elsif filename.match?(BUILD_FILE_PATTERN)
            process_build_file(context, full_entry_path)
          end
        end
      end
    end
  rescue Errno::ENOENT
    context.logger.error("DIRS file not found: #{absolute_path}")
    context.exit_handler.exit_with_code(1)
  rescue => e
    context.logger.error("Error reading DIRS file #{absolute_path}: #{e.message}")
    context.exit_handler.exit_with_code(1)
  end
end

# --- Main Execution Logic ---

context = get_context

begin
  if RUBY_PLATFORM.match?(/mingw|mswin/i)
    context.logger.info('Windows platform detected. Attempting MSVC environment setup...')
    setup_msvc_env(context)
    context.logger.info('MSVC environment setup complete. Continuing build.')
  else
    context.logger.info('Non-Windows platform detected. Skipping MSVC setup.')
  end
rescue => e
  context.logger.fatal("Failed during MSVC environment setup: #{e.message}")
  context.logger.fatal(e.backtrace.join("\n"))
  context.exit_handler.exit_with_code(1)
end

arguments = context.command_line_arguments_provider.arguments
if arguments.length == 1
  user_provided_path = arguments[0]
  if File.file?(user_provided_path) && File.basename(user_provided_path).match?(BUILD_FILE_PATTERN)
    absolute_path = File.absolute_path(user_provided_path)
    context.logger.info('User requested single BUILD file execution:')
    context.logger.info("> #{absolute_path}")
    process_build_file(context, absolute_path)
    context.logger.info('--------------------------------')
    context.logger.info('Single BUILD file finished successfully.')
    context.exit_handler.exit_with_code(0)
  else
    context.logger.error("Provided path is not a valid BUILD file: #{user_provided_path}")
    context.exit_handler.exit_with_code(1)
  end
end

start_directory = Dir.pwd
context.logger.info("Starting build scan in: #{start_directory}")

begin
  Dir.foreach(start_directory) do |entry|
    next if entry == '.' || entry == '..'
    entry_path = File.join(start_directory, entry)

    if File.file?(entry_path)
      filename = File.basename(entry_path)
      if filename == DIRS_FILE_NAME
        process_dirs_file(context, entry_path)
      elsif filename.match?(BUILD_FILE_PATTERN)
        process_build_file(context, entry_path)
      end
    end
  end
rescue => e
  context.logger.error("An unexpected error occurred during initial scan: #{e.message}")
  context.logger.error(e.backtrace.join("\n"))
  context.exit_handler.exit_with_code(1)
end

context.logger.info('--------------------------------')
context.logger.info('Build finished successfully.')
context.exit_handler.exit_with_code(0)
