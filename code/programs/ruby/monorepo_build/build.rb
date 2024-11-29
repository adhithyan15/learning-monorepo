require 'open3'

puts "Let's build the codebase"

# Function to execute a shell command
def execute_command(command)
  stdout, stderr, status = Open3.capture3(command)
  puts "Running Command: #{command}"
  if status.success?
    puts "Output:\n#{stdout.strip}"
  else
    puts "Command failed!"
    puts "Error:\n#{stderr.strip}"
    exit(status.exitstatus) # Exit the program with the command's exit status
  end
end

def strip_newlines_and_spaces(input)
    input.gsub(/\s+/, '') # Removes all spaces and newlines
  end

def process_build_file(build_file_path)
    puts "Detected a BUILD file in #{build_file_path}"
    if build_file_path.include?("_windows")
        unless (RUBY_PLATFORM.include?("mingw32") || RUBY_PLATFORM.include?("mswin"))
            puts "Not a Windows OS. Skipping this build file"
            return
        end
    end
    if build_file_path.include?("_mac")
        unless RUBY_PLATFORM.include?("darwin")
            puts "Not a Mac OS. Skipping the build file"
            return
        end
    end
    if build_file_path.include?("_linux")
        unless RUBY_PLATFORM.include?("linux")
            puts "Not a Linux based OS. Skipping the build file"
            return
        end
    end
    current_directory = File.dirname(build_file_path)
    cached_current_working_directory = Dir.pwd
    Dir.chdir(current_directory)
    build_file_contents = File.readlines(build_file_path)
    build_file_contents.each do |file_content|
        execute_command(file_content)
    end
    Dir.chdir(cached_current_working_directory)
end

def process_dirs_file(dirs_file_path)
    puts "Detected a DIRS file  in #{dirs_file_path}"
    # Dirs file requires further recursion
    dirs_file_contents = File.readlines(dirs_file_path)
    dirs_file_contents.each do |next_dir_path|
        stripped_path = strip_newlines_and_spaces(next_dir_path)
        full_next_dir_path = File.join([File.dirname(dirs_file_path), stripped_path])
        Dir.foreach(full_next_dir_path) do |dir_content|
            full_path = File.join([full_next_dir_path, dir_content])
            if File.file?(full_path)
                if full_path.include?("DIRS")
                    process_dirs_file(full_path)
                elsif full_path.include?("BUILD")
                    process_build_file(full_path)
                end
            end
        end
    end
end

folder_path = Dir.pwd

Dir.foreach(folder_path) do |entry|
    next if entry == '.' || entry == '..' # Skip special entries

    entry_path = File.join(folder_path, entry)
    if File.file?(entry_path)
        if entry.eql?("DIRS")
            process_dirs_file(entry_path)
        elsif entry.eql?("BUILD")
            process_build_file(entry_path)
        end
    end
end

