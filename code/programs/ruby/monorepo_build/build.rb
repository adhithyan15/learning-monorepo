require 'open3'
require 'set' # Used for tracking processed DIRS files to prevent infinite loops

puts "[INFO] Starting the build process..."

# --- Configuration ---
BUILD_FILE_PATTERN = /^BUILD(?:_windows|_mac_and_linux|_mac|_linux)?$/
DIRS_FILE_NAME = "DIRS"
BUILD_COMMENT_CHAR = '#'

# --- Global State ---
# Keep track of processed DIRS files to avoid cycles
$processed_dirs_files = Set.new

# --- Helper Functions ---

# Function to execute a single shell command
# Exits script immediately on failure.
def execute_command(command, current_working_directory)
  puts "[CMD] In '#{current_working_directory}': #{command}"
  stdout_str, stderr_str, status = Open3.capture3(command, chdir: current_working_directory)

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
    is_windows = RUBY_PLATFORM.include?("mingw32") || RUBY_PLATFORM.include?("mswin")
    is_mac = RUBY_PLATFORM.include?("darwin")
    is_linux = RUBY_PLATFORM.include?("linux")

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

# --- Core Processing Functions ---

# Processes a BUILD file, executing its commands.
# Will exit script via execute_command on first failure.
def process_build_file(build_file_path)
  absolute_path = File.absolute_path(build_file_path)
  puts "[INFO] Processing BUILD file: #{absolute_path}"

  unless check_os_match(absolute_path)
    puts "[INFO] Skipping #{absolute_path} due to OS mismatch."
    return # Not an error, just skip
  end

  current_directory = File.dirname(absolute_path)

  begin
    build_file_contents = File.readlines(absolute_path)
    build_file_contents.each_with_index do |line, index|
      command = line.strip
      # Skip empty lines and comments
      next if command.empty? || command.start_with?(BUILD_COMMENT_CHAR)
      # execute_command will exit immediately if it fails
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

      puts "[INFO] Scanning directory: #{full_next_dir_path}"
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
start_directory = Dir.pwd
puts "[INFO] Starting scan in: #{start_directory}"

begin
  Dir.foreach(start_directory) do |entry|
      next if entry == '.' || entry == '..'
      entry_path = File.join(start_directory, entry)

      if File.file?(entry_path)
          filename = File.basename(entry_path)
          if filename == DIRS_FILE_NAME
              process_dirs_file(entry_path)
          elsif filename.match?(BUILD_FILE_PATTERN)
              process_build_file(entry_path)
          end
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