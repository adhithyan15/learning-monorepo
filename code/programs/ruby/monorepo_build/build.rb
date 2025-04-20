require 'open3'
require 'set' # Used for tracking processed DIRS files AND for path de-duplication
require 'pathname' # Needed by MSVC setup code

puts "[INFO] Starting the build process..."

# ==================================================
# MSVC Environment Setup Code (for Windows)
# ==================================================

# --- Helper Functions for MSVC Setup ---

# Simple function to find vswhere (adjust path if necessary)
def find_vswhere
  # Standard location in Program Files (x86)
  vswhere_path = Pathname.new(ENV['ProgramFiles(x86)']) / 'Microsoft Visual Studio' / 'Installer' / 'vswhere.exe'
  return vswhere_path.to_s if vswhere_path.exist?

  # Maybe it's already in PATH?
  # Simple check; a more robust check would search PATH directories.
  output, status = Open3.capture2('where vswhere.exe')
  return output.lines.first.strip if status.success? && !output.empty?

  raise "vswhere.exe not found at standard location or in PATH. Cannot locate Visual Studio."
end

# Finds the vcvarsall.bat script using vswhere
# vs_version: e.g., '17.0' for VS 2022, '16.0' for VS 2019, or nil for latest
def find_vcvarsall(vs_version = nil)
  vswhere_exe = find_vswhere

  # Base command arguments for vswhere
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

# Parses the output of the 'set' command into a Hash
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

# Checks if a variable name typically holds path list
def is_path_variable?(name)
  name.match?(/^(PATH|LIB|INCLUDE|LIBPATH)$/i)
end

# Cleans up path variables by removing duplicate entries
def filter_path_value(path_string)
  Set.new(path_string.split(';').reject(&:empty?)).to_a.join(';')
end


# --- Main Function to Setup MSVC Environment ---
# arch: e.g., "x64", "x86", "arm64"
# sdk: e.g., "10.0.19041.0" (optional)
# toolset: e.g., "14.38" (optional, corresponds to -vcvars_ver)
# uwp: boolean (optional, adds 'uwp' argument)
# spectre: boolean (optional, adds '-vcvars_spectre_libs=spectre')
# vs_version: e.g., "17.0" (optional, for find_vcvarsall)
def setup_msvc_env(arch: 'x64', sdk: nil, toolset: nil, uwp: false, spectre: false, vs_version: nil)
  # 1. Platform already checked before calling this function

  # 2. Find vcvarsall.bat
  begin
    vcvarsall_path = find_vcvarsall(vs_version)
    puts "[INFO] MSVC: Found vcvarsall.bat at: #{vcvarsall_path}"
  rescue => e
    puts "[ERR] MSVC: Failed to find vcvarsall.bat: #{e.message}"
    raise # Re-raise the exception to halt the script (fail fast)
  end

  # 3. Construct vcvarsall arguments
  vcvars_args = [arch] # Architecture is required
  vcvars_args << 'uwp' if uwp
  vcvars_args << sdk if sdk
  vcvars_args << "-vcvars_ver=#{toolset}" if toolset
  vcvars_args << '-vcvars_spectre_libs=spectre' if spectre

  vcvars_command = %("#{vcvarsall_path}" #{vcvars_args.join(' ')})
  puts "[INFO] MSVC: vcvars command line: #{vcvars_command}"

  # 4. Execute the core command to capture environment changes
  full_command = "set && cls && #{vcvars_command} && cls && set"
  puts "[DEBUG] MSVC: Executing: #{full_command}"
  output, status = Open3.capture2e("cmd /c \"#{full_command}\"")

  unless status.success?
      puts "[WARN] MSVC: Environment capture command execution might have failed. Status: #{status.exitstatus}"
      puts "[WARN] MSVC: Output was:\n#{output}"
      # Fail fast if the capture command itself fails significantly
      raise "Failed to execute MSVC environment capture command. Status: #{status.exitstatus}" if status.exitstatus != 0
  end

  # 5. Parse the output
  output_parts = output.split("\f") # Split by the form feed from cls
  unless output_parts.length == 3
    puts "[ERR] MSVC: Unexpected output format when splitting by form feed (cls)."
    puts "[ERR] MSVC: Expected 3 parts, got #{output_parts.length}."
    puts "[ERR] MSVC: Full output:\n#{output}"
    raise "Failed to parse MSVC environment capture output."
  end

  before_env_lines = output_parts[0].lines
  vcvars_out_lines = output_parts[1].lines # Messages from vcvarsall itself
  after_env_lines  = output_parts[2].lines

  # 6. Check vcvarsall output for errors
  error_messages = vcvars_out_lines.map(&:strip).select do |line|
    line.match?(/^\[ERROR.*\]/i) && !line.match?(/Error in script usage. The correct usage is:/)
  end

  unless error_messages.empty?
    puts "[ERR] MSVC: vcvarsall.bat reported errors:"
    error_messages.each { |err| puts "- #{err}" }
    raise "vcvarsall.bat failed with errors. See log for details."
  end

  # 7. Parse environments and diff
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

      # 8. Apply Changes to Current Ruby Process Environment (ENV hash)
      ENV[key] = final_value
    end
  end

  puts "[INFO] MSVC: Environment configured successfully."
  puts "[INFO] MSVC: #{new_vars} new variables, #{changed_vars} changed variables applied to current process environment."
end
# ==================================================
# End of MSVC Environment Setup Code
# ==================================================


# --- Configuration ---
BUILD_FILE_PATTERN = /^BUILD(?:_windows|_mac_and_linux|_mac|_linux)?$/
DIRS_FILE_NAME = "DIRS"
BUILD_COMMENT_CHAR = '#'

# --- Global State ---
# Keep track of processed DIRS files to avoid cycles
$processed_dirs_files = Set.new

# --- Helper Functions (Your Existing Helpers) ---

# Function to execute a single shell command
# Exits script immediately on failure.
def execute_command(command, current_working_directory)
  puts "[CMD] In '#{current_working_directory}': #{command}"
  # Pass the current ENV which now includes MSVC vars if on Windows
  stdout_str, stderr_str, status = Open3.capture3(ENV, command, chdir: current_working_directory)

  if status.success?
    puts "[OUT] #{stdout_str.strip}" unless stdout_str.strip.empty?
  else
    puts "[ERR] Command failed! (Exit Status: #{status.exitstatus})"
    puts "[ERR] #{stderr_str.strip}" unless stderr_str.strip.empty?
    exit(status.exitstatus) # FAIL FAST: Exit with the command's status
  end
rescue => e
  # Catch errors like command not found
  puts "[ERR] Failed to execute command '#{command}' in '#{current_working_directory}': #{e.message}"
  exit(1) # FAIL FAST: Exit with a generic error code
end

# Function to check if the build file should run on the current OS
def check_os_match(build_file_path)
    filename = File.basename(build_file_path)
    # Use more robust check for Windows platform variants
    is_windows = RUBY_PLATFORM.match?(/mingw|mswin/i)
    is_mac = RUBY_PLATFORM.include?("darwin")
    is_linux = !is_windows && !is_mac && RUBY_PLATFORM.include?("linux") # Be more specific for Linux

    case filename
    when /_windows$/
      is_windows
    when /_mac_and_linux$/
      is_mac || is_linux
    when /_mac$/
      is_mac
    when /_linux$/
      is_linux
    else # BUILD file without suffix runs everywhere
      true
    end
end

# --- Core Processing Functions (Your Existing Functions) ---

# Processes a BUILD file, executing its commands.
# Will exit script via execute_command on first failure.
def process_build_file(build_file_path)
  absolute_path = File.absolute_path(build_file_path)

  unless check_os_match(absolute_path)
    puts "[INFO] Skipping BUILD file #{File.basename(absolute_path)} in #{File.dirname(absolute_path)} due to OS mismatch."
    return # Not an error, just skip
  end

  puts "[INFO] Processing BUILD file: #{absolute_path}"
  current_directory = File.dirname(absolute_path)

  begin
    build_file_contents = File.readlines(absolute_path)
    build_file_contents.each_with_index do |line, index|
      command = line.strip
      # Skip empty lines and comments
      next if command.empty? || command.start_with?(BUILD_COMMENT_CHAR)
      # execute_command will exit immediately if it fails
      # It automatically uses the updated ENV
      execute_command(command, current_directory)
    end
  rescue Errno::ENOENT
    puts "[ERR] Build file not found: #{absolute_path}"
    exit(1) # FAIL FAST
  rescue => e
    puts "[ERR] Error reading build file #{absolute_path}: #{e.message}"
    exit(1) # FAIL FAST
  end
end

# Processes a DIRS file, recursively processing items in listed subdirectories.
# Will exit script via recursive calls if any failure occurs.
def process_dirs_file(dirs_file_path)
  absolute_path = File.absolute_path(dirs_file_path)

  # Prevent infinite loops
  if $processed_dirs_files.include?(absolute_path)
     puts "[WARN] Already processed DIRS file #{absolute_path}, skipping to prevent infinite loop."
     return # Not an error
  end
  $processed_dirs_files.add(absolute_path)

  puts "[INFO] Processing DIRS file: #{absolute_path}"
  current_directory = File.dirname(absolute_path)

  begin
    dirs_file_contents = File.readlines(absolute_path)
    dirs_file_contents.each do |next_dir_rel_path|
      stripped_path = next_dir_rel_path.strip
      next if stripped_path.empty? || stripped_path.start_with?(BUILD_COMMENT_CHAR)

      full_next_dir_path = File.absolute_path(File.join(current_directory, stripped_path))

      unless Dir.exist?(full_next_dir_path)
        puts "[WARN] Directory '#{full_next_dir_path}' listed in #{absolute_path} not found. Skipping."
        next # Skip this entry
      end

      # Scan the listed directory for BUILD or DIRS files
      # Avoid puts clutter here unless necessary, focus on processing
      # puts "[INFO] Scanning directory: #{full_next_dir_path}"
      Dir.foreach(full_next_dir_path) do |entry|
        next if entry == '.' || entry == '..'
        full_entry_path = File.join(full_next_dir_path, entry)

        if File.file?(full_entry_path)
          filename = File.basename(full_entry_path)

          if filename == DIRS_FILE_NAME
            # Recursive call - will exit if failure occurs within
            process_dirs_file(full_entry_path)
          elsif filename.match?(BUILD_FILE_PATTERN)
            # Process BUILD - will exit if failure occurs within
            process_build_file(full_entry_path)
          end
        end
      end # End Dir.foreach
    end # End dirs_file_contents.each

  rescue Errno::ENOENT
    puts "[ERR] DIRS file not found: #{absolute_path}"
    exit(1) # FAIL FAST
  rescue => e
    puts "[ERR] Error reading DIRS file #{absolute_path}: #{e.message}"
    exit(1) # FAIL FAST
  end
end

# --- Main Execution Logic ---

# ** SETUP MSVC ENV IF ON WINDOWS **
begin
  if RUBY_PLATFORM.match?(/mingw|mswin/i)
    puts "[INFO] Windows platform detected. Attempting MSVC environment setup..."
    # Call the setup function - use defaults or specify options
    # e.g., setup_msvc_env(arch: 'x64', vs_version: '17.0')
    setup_msvc_env() # Using defaults (likely latest VS, x64)
    puts "[INFO] MSVC environment setup complete. Continuing build."
  else
    puts "[INFO] Non-Windows platform detected. Skipping MSVC setup."
  end
rescue => e
  puts "[FATAL ERR] Failed during MSVC environment setup: #{e.message}"
  puts e.backtrace.join("\n")
  exit(1) # Fail fast if MSVC setup fails
end
# ************************************

# --- Shortcut Mode: Build a Single BUILD File ---
if ARGV.length == 1
  user_provided_path = ARGV[0]
  if File.file?(user_provided_path) && File.basename(user_provided_path).match?(BUILD_FILE_PATTERN)
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

begin
  # Initial scan of the top-level directory
  Dir.foreach(start_directory) do |entry|
     next if entry == '.' || entry == '..'
     entry_path = File.join(start_directory, entry)

     if File.file?(entry_path)
       filename = File.basename(entry_path)
       if filename == DIRS_FILE_NAME
         process_dirs_file(entry_path) # Start recursion
       elsif filename.match?(BUILD_FILE_PATTERN)
         process_build_file(entry_path) # Process top-level build file
       end
     elsif File.directory?(entry_path)
       # Optional: If you want to scan subdirs even without a top-level DIRS
       # you might add logic here, but based on your script, it seems
       # driven entirely by DIRS files after the initial scan.
     end
  end
rescue => e
   # Catch unexpected errors during the initial scan itself
   puts "[ERR] An unexpected error occurred during initial scan: #{e.message}"
   puts e.backtrace.join("\n")
   exit(1) # FAIL FAST
end

# --- Final Status ---
# If the script reaches this point, everything succeeded
puts "\n--------------------------------"
puts "[INFO] Build finished successfully."
exit(0)