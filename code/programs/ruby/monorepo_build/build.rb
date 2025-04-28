require 'open3'
require 'set'
require 'pathname'

require_relative 'lib/get_context'

# --- Configuration ---
BUILD_FILE_PATTERN = /^BUILD(?:_windows|_mac_and_linux|_mac|_linux)?$/
DIRS_FILE_NAME = "DIRS"
BUILD_COMMENT_CHAR = '#'

# ==================================================
# MSVC Environment Setup Code (for Windows)
# ==================================================

def find_vswhere
  vswhere_path = Pathname.new(ENV['ProgramFiles(x86)']) / 'Microsoft Visual Studio' / 'Installer' / 'vswhere.exe'
  return vswhere_path.to_s if vswhere_path.exist?

  output, status = Open3.capture2('where vswhere.exe')
  return output.lines.first.strip if status.success? && !output.empty?

  raise "vswhere.exe not found at standard location or in PATH. Cannot locate Visual Studio."
end

def find_vcvarsall(vs_version = nil)
  vswhere_exe = find_vswhere

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

def setup_msvc_env(arch: 'x64', sdk: nil, toolset: nil, uwp: false, spectre: false, vs_version: nil)
  begin
    vcvarsall_path = find_vcvarsall(vs_version)
    puts "[INFO] MSVC: Found vcvarsall.bat at: #{vcvarsall_path}"
  rescue => e
    puts "[ERR] MSVC: Failed to find vcvarsall.bat: #{e.message}"
    raise
  end

  vcvars_args = [arch]
  vcvars_args << 'uwp' if uwp
  vcvars_args << sdk if sdk
  vcvars_args << "-vcvars_ver=#{toolset}" if toolset
  vcvars_args << '-vcvars_spectre_libs=spectre' if spectre

  vcvars_command = %("#{vcvarsall_path}" #{vcvars_args.join(' ')})
  puts "[INFO] MSVC: vcvars command line: #{vcvars_command}"

  full_command = "set && cls && #{vcvars_command} && cls && set"
  puts "[DEBUG] MSVC: Executing: #{full_command}"
  output, status = Open3.capture2e("cmd /c \"#{full_command}\"")

  unless status.success?
    puts "[WARN] MSVC: Environment capture command execution might have failed. Status: #{status.exitstatus}"
    puts "[WARN] MSVC: Output was:\n#{output}"
    raise "Failed to execute MSVC environment capture command. Status: #{status.exitstatus}" if status.exitstatus != 0
  end

  output_parts = output.split("\f")
  unless output_parts.length == 3
    puts "[ERR] MSVC: Unexpected output format when splitting by form feed (cls)."
    puts "[ERR] MSVC: Expected 3 parts, got #{output_parts.length}."
    puts "[ERR] MSVC: Full output:\n#{output}"
    raise "Failed to parse MSVC environment capture output."
  end

  before_env_lines = output_parts[0].lines
  vcvars_out_lines = output_parts[1].lines
  after_env_lines  = output_parts[2].lines

  error_messages = vcvars_out_lines.map(&:strip).select do |line|
    line.match?(/^\[ERROR.*\]/i) && !line.match?(/Error in script usage. The correct usage is:/)
  end

  unless error_messages.empty?
    puts "[ERR] MSVC: vcvarsall.bat reported errors:"
    error_messages.each { |err| puts "- #{err}" }
    raise "vcvarsall.bat failed with errors. See log for details."
  end

  puts "[INFO] MSVC: Processing environment variables..."
  before_env = parse_env(before_env_lines)
  after_env = parse_env(after_env_lines)

  changed_vars = 0
  new_vars = 0

  after_env.each do |key, new_value|
    old_value = before_env[key]

    if new_value != old_value
      if old_value.nil?
        new_vars += 1
      else
        changed_vars += 1
      end

      final_value = if is_path_variable?(key)
                      filter_path_value(new_value)
                    else
                      new_value
                    end

      ENV[key] = final_value
    end
  end

  puts "[INFO] MSVC: Environment configured successfully."
  puts "[INFO] MSVC: #{new_vars} new variables, #{changed_vars} changed variables applied to current process environment."
end

# ==================================================
# End of MSVC Environment Setup Code
# ==================================================

# --- Helper Functions ---

def execute_command(command, current_working_directory)
  puts "[CMD] In '#{current_working_directory}': #{command}"
  stdout_str, stderr_str, status = Open3.capture3(ENV, command, chdir: current_working_directory)

  if status.success?
    puts "[OUT] #{stdout_str.strip}" unless stdout_str.strip.empty?
  else
    puts "[ERR] Command failed! (Exit Status: #{status.exitstatus})"
    puts "[ERR] #{stderr_str.strip}" unless stderr_str.strip.empty?
    exit(status.exitstatus)
  end
rescue => e
  puts "[ERR] Failed to execute command '#{command}' in '#{current_working_directory}': #{e.message}"
  exit(1)
end

def check_os_match(build_file_path)
  filename = File.basename(build_file_path)
  is_windows = RUBY_PLATFORM.match?(/mingw|mswin/i)
  is_mac = RUBY_PLATFORM.include?("darwin")
  is_linux = !is_windows && !is_mac && RUBY_PLATFORM.include?("linux")

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

def process_build_file(build_file_path)
  absolute_path = File.absolute_path(build_file_path)

  unless check_os_match(absolute_path)
    puts "[INFO] Skipping BUILD file #{File.basename(absolute_path)} in #{File.dirname(absolute_path)} due to OS mismatch."
    return
  end

  puts "[INFO] Processing BUILD file: #{absolute_path}"
  current_directory = File.dirname(absolute_path)

  begin
    build_file_contents = File.readlines(absolute_path)
    build_file_contents.each_with_index do |line, index|
      command = line.strip
      next if command.empty? || command.start_with?(BUILD_COMMENT_CHAR)
      execute_command(command, current_directory)
    end
  rescue Errno::ENOENT
    puts "[ERR] Build file not found: #{absolute_path}"
    exit(1)
  rescue => e
    puts "[ERR] Error reading build file #{absolute_path}: #{e.message}"
    exit(1)
  end
end

def process_dirs_file(dirs_file_path, context)
  absolute_path = File.absolute_path(dirs_file_path)

  if context.file_processing_history.already_processed?(absolute_path)
    puts "[WARN] Already processed DIRS file #{absolute_path}, skipping to prevent infinite loop."
    return
  end
  context.file_processing_history.mark_processed(absolute_path)

  puts "[INFO] Processing DIRS file: #{absolute_path}"
  current_directory = File.dirname(dirs_file_path)

  begin
    dirs_file_contents = File.readlines(dirs_file_path)
    dirs_file_contents.each do |next_dir_rel_path|
      stripped_path = next_dir_rel_path.strip
      next if stripped_path.empty? || stripped_path.start_with?(BUILD_COMMENT_CHAR)

      full_next_dir_path = File.absolute_path(File.join(current_directory, stripped_path))

      unless Dir.exist?(full_next_dir_path)
        puts "[WARN] Directory '#{full_next_dir_path}' listed in #{absolute_path} not found. Skipping."
        next
      end

      Dir.foreach(full_next_dir_path) do |entry|
        next if entry == '.' || entry == '..'
        full_entry_path = File.join(full_next_dir_path, entry)

        if File.file?(full_entry_path)
          filename = File.basename(full_entry_path)

          if filename == DIRS_FILE_NAME
            process_dirs_file(full_entry_path, context)
          elsif filename.match?(BUILD_FILE_PATTERN)
            process_build_file(full_entry_path)
          end
        end
      end
    end
  rescue Errno::ENOENT
    puts "[ERR] DIRS file not found: #{absolute_path}"
    exit(1)
  rescue => e
    puts "[ERR] Error reading DIRS file #{absolute_path}: #{e.message}"
    exit(1)
  end
end

# --- Main Execution Logic ---

begin
  if RUBY_PLATFORM.match?(/mingw|mswin/i)
    puts "[INFO] Windows platform detected. Attempting MSVC environment setup..."
    setup_msvc_env()
    puts "[INFO] MSVC environment setup complete. Continuing build."
  else
    puts "[INFO] Non-Windows platform detected. Skipping MSVC setup."
  end
rescue => e
  puts "[FATAL ERR] Failed during MSVC environment setup: #{e.message}"
  puts e.backtrace.join("\n")
  exit(1)
end

if ARGV.length == 1
  user_provided_path = ARGV[0]
  if File.file?(user_provided_path) && File.basename(user_provided_path).match?(BUILD_FILE_PATTERN)
    context = get_context
    absolute_path = File.absolute_path(user_provided_path)
    puts "[INFO] User requested single BUILD file execution:"
    puts "[INFO] > #{absolute_path}"
    process_build_file(absolute_path)
    puts "\n--------------------------------"
    puts "[INFO] Single BUILD file finished successfully."
    exit(0)
  else
    puts "[ERR] Provided path is not a valid BUILD file: #{user_provided_path}"
    exit(1)
  end
end

start_directory = Dir.pwd
puts "[INFO] Starting build scan in: #{start_directory}"

context = get_context

begin
  Dir.foreach(start_directory) do |entry|
    next if entry == '.' || entry == '..'
    entry_path = File.join(start_directory, entry)

    if File.file?(entry_path)
      filename = File.basename(entry_path)
      if filename == DIRS_FILE_NAME
        process_dirs_file(entry_path, context)
      elsif filename.match?(BUILD_FILE_PATTERN)
        process_build_file(entry_path)
      end
    end
  end
rescue => e
  puts "[ERR] An unexpected error occurred during initial scan: #{e.message}"
  puts e.backtrace.join("\n")
  exit(1)
end

puts "\n--------------------------------"
puts "[INFO] Build finished successfully."
exit(0)
