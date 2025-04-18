require 'fileutils'
require 'json'
require 'pathname'
require 'open3' # For better command execution and error handling

# --- Helper Functions ---

# Executes a shell command in a specified directory
# Raises an error if the command fails
def run_command(command, dir)
  stdout, stderr, status = Open3.capture3(command, chdir: dir)
  unless status.success?
    STDERR.puts "❌ Error executing command: #{command}"
    STDERR.puts stderr
    exit(1)
  end
  puts stdout # Show command output
end

# Writes content to a file, ensuring a newline at the end
def write_file(file_path, contents)
  File.write(file_path, contents + "\n", mode: 'w', encoding: 'utf-8')
end

# --- Main Script ---

package_name = ARGV[0]
target_path = ARGV[1] || '.'

# Step 0: Validate arguments
unless package_name
  STDERR.puts "❌ Please provide a package name."
  STDERR.puts "Usage: ruby create-ts-package.rb <package-name> [target-path]"
  exit(1)
end

# --- Setup Paths ---
base_dir = Pathname.new(target_path).expand_path
package_dir = base_dir.join(package_name)
src_dir = package_dir.join("src")

# Step 1: Create directories
puts "Creating directories..."
FileUtils.mkdir_p(package_dir)
FileUtils.mkdir_p(src_dir)

# Step 2: Initialize package.json
puts "Initializing npm package..."
run_command("npm init -y", package_dir.to_s)

# Step 3: Install TypeScript
puts "Installing TypeScript..."
run_command("npm install --save-dev typescript", package_dir.to_s)

# Step 4: Create tsconfig.json
puts "Creating tsconfig.json..."
tsconfig_path = package_dir.join("tsconfig.json")
tsconfig_content = {
  compilerOptions: {
    target: "ES2019",
    module: "ESNext",
    moduleResolution: "Node",
    declaration: true,
    outDir: "dist",
    rootDir: "src",
    strict: true,
    esModuleInterop: true,
    forceConsistentCasingInFileNames: true,
    skipLibCheck: true,
  },
  include: ["src"],
}
write_file(tsconfig_path, JSON.pretty_generate(tsconfig_content))

# Step 5: Create example source file
puts "Creating example source file..."
index_ts_path = src_dir.join("index.ts")
index_ts_content = <<~TYPESCRIPT
  export function greet(name: string): string {
    return `Hello, ${name}!`;
  }
TYPESCRIPT
write_file(index_ts_path, index_ts_content)

# Step 6: Modify package.json
puts "Updating package.json..."
pkg_json_path = package_dir.join("package.json")
pkg_json_content = JSON.parse(File.read(pkg_json_path))

pkg_json_content['main'] = "dist/index.js"
pkg_json_content['types'] = "dist/index.d.ts"
pkg_json_content['scripts'] = {
  "build" => "tsc",
}
pkg_json_content['exports'] = {
  "." => {
    "import" => "./dist/index.js",
    "require" => "./dist/index.js",
  },
}

# Ensure "name" matches the folder name if desired (npm init -y might use the directory name)
pkg_json_content['name'] = package_name unless pkg_json_content['name'] == package_name

write_file(pkg_json_path, JSON.pretty_generate(pkg_json_content))

# Step 7: Add .npmignore
puts "Creating .npmignore..."
npmignore_path = package_dir.join(".npmignore")
npmignore_content = <<~IGNORE
  src/
  tsconfig.json
  *.log
IGNORE
write_file(npmignore_path, npmignore_content)

# Step 8: Add .gitignore
puts "Creating .gitignore..."
gitignore_path = package_dir.join(".gitignore")
gitignore_content = <<~IGNORE
  node_modules/
  dist/
  *.log
  .env
  .DS_Store
IGNORE
write_file(gitignore_path, gitignore_content)

# Step 9: Add empty README.md
puts "Creating README.md..."
readme_path = package_dir.join("README.md")
write_file(readme_path, "# #{package_name}\n") # Add a basic title

# --- Completion Message ---
puts "\n✅ Package '#{package_name}' created successfully at '#{package_dir}'."
puts "👉 To build it:"
puts "   cd #{package_dir} && npm run build"