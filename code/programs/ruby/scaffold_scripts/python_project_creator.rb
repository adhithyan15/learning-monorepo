require 'fileutils'
require 'optparse'

# --- Configuration ---
PYTHON_MIN_VERSION = "3.11"
# --- End Configuration ---

# --- Helper Functions ---
def sanitize_package_name(name)
  name.gsub('-', '_').gsub(/[^0-9a-zA-Z_]/, '')
end

def create_file(path, content)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, content)
  puts "  Created: #{path}"
rescue StandardError => e
  puts "  Error creating #{path}: #{e.message}"
end

# --- Argument Parsing ---
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options] <project_name>"
  opts.on("-p", "--path PATH", String, "Specify the parent directory path where the project directory should be created") { |p| options[:path] = p }
  opts.on("-h", "--help", "Prints this help") { puts opts; exit }
end.parse!

project_name = ARGV.shift
unless project_name
  puts "Error: Project name is required."
  puts "Usage: #{$PROGRAM_NAME} [--path DIR] <project_name>"
  exit 1
end

package_name = sanitize_package_name(project_name)
if package_name.empty?
  puts "Error: Could not derive a valid package name from '#{project_name}'."
  exit 1
end

# --- Define Paths ---
base_dir = options[:path] ? File.expand_path(options[:path]) : Dir.pwd
project_dir = File.join(base_dir, project_name)
# --- SRC LAYOUT CHANGES START ---
src_root_dir = File.join(project_dir, 'src') # Define the src/ directory
package_source_dir = File.join(src_root_dir, package_name) # Package code goes inside src/
# --- SRC LAYOUT CHANGES END ---
tests_dir = File.join(project_dir, 'tests') # Tests remain at the root

puts "Scaffolding Python project '#{project_name}' (package '#{package_name}') in '#{base_dir}' using src layout..."

# --- Check if project directory exists and create if necessary ---
if Dir.exist?(project_dir)
  puts "Warning: Project directory '#{project_dir}' already exists. Files might be overwritten."
else
  begin
    FileUtils.mkdir_p(project_dir)
    puts "Created project directory: #{project_dir}"
  rescue StandardError => e
    puts "Error creating project directory #{project_dir}: #{e.message}"
    exit 1
  end
end

# --- Create Subdirectories (src/, src/package_name/, tests/) ---
# --- SRC LAYOUT CHANGE: Added src_root_dir ---
[src_root_dir, package_source_dir, tests_dir].each do |dir|
   begin
     FileUtils.mkdir_p(dir)
     # Only print creation message if it didn't exist before this run
     puts "  Created subdirectory: #{dir.gsub(project_dir + File::SEPARATOR, '')}" unless Dir.exist?(dir) && !File.empty?(dir) # Basic check, show relative path
   rescue StandardError => e
     puts "Error creating subdirectory #{dir}: #{e.message}"
   end
end


# --- Create Files ---

# 1. pyproject.toml (UPDATED for src layout)
pyproject_content = <<~TOML
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "#{project_name}"
version = "0.1.0"
authors = [
  { name="Your Name", email="you@example.com" }, # TODO: Change me
]
description = "A sample Python package: #{project_name}" # TODO: Change me
readme = "README.md"
requires-python = ">=#{PYTHON_MIN_VERSION}"
classifiers = [
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "License :: OSI Approved :: MIT License", # TODO: Choose your license
    "Operating System :: OS Independent",
]
# dependencies = [] # Runtime dependencies

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-cov>=4.0",
    "mypy>=1.0",
    "ruff>=0.1",
    "pre-commit>=3.0",
    # "build",
    # "twine",
]

# --- SRC LAYOUT CHANGE IN SETuptools CONFIG ---
[tool.setuptools]
# Tell setuptools that packages are under the 'src' directory
package-dir = {"" = "src"}

[tool.setuptools.packages.find]
# Automatically find packages within the 'src' directory
where = ["src"]
# Alternatively, if you prefer explicit declaration with src layout:
# packages = ["#{package_name}"] # (But ensure package-dir above is also set)
# --- END SRC LAYOUT CHANGE ---


[tool.pytest.ini_options]
minversion = "7.0"
# Pytest should find the installed package even with src layout when installed editable
addopts = "-ra -q --cov=#{package_name} --cov-report=term-missing"
testpaths = [
    "tests",
]

[tool.mypy]
python_version = "#{PYTHON_MIN_VERSION}"
warn_return_any = true
warn_unused_configs = true
# With src layout, mypy needs to know where the code is.
# Setting 'mypy_path' or configuring 'tool.setuptools' might help it find it,
# or you'll run mypy specifically on the src and tests dirs (see README).
# packages = ["#{package_name}"] # Can help mypy find the package

[tool.ruff]
line-length = 88
target-version = "py#{PYTHON_MIN_VERSION.gsub('.', '')}"

[tool.ruff.lint]
select = [ "E", "W", "F", "I", "UP", "B" ]
ignore = []

[tool.ruff.format]
# Optional formatting configurations

#[tool.coverage.run]
#source = ["src/#{package_name}"] # Coverage source might need adjusting for src layout

TOML
create_file(File.join(project_dir, 'pyproject.toml'), pyproject_content)

# 2. README.md (UPDATED mypy command)
readme_content = <<~MD
# #{project_name}

A brief description of your project.

## Installation

\`\`\`bash
# Navigate to the project directory first if needed:
# cd path/to/#{project_name}

# Create and activate virtual environment (Recommended)
python3 -m venv .venv
source .venv/bin/activate  # macOS/Linux
# .\.venv\Scripts\activate  # Windows

# Install the package in editable mode with development dependencies
# Editable install makes the code in src/ available for import
pip install -e .[dev]
\`\`\`

## Usage

\`\`\`python
# TODO: Add usage examples here
# Example (assuming package is installed):
# from #{package_name} import placeholder_function
#
# result = placeholder_function(1)
# print(result)
\`\`\`

## Development Workflow

This project uses a `src` layout, `ruff` for linting/formatting, and `pytest` for testing. `pre-commit` is configured to run checks automatically.

1.  **Set up Environment (if not done during Installation):**
    \`\`\`bash
    cd path/to/#{project_name}
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -e .[dev]
    \`\`\`

2.  **Install Git Hooks (One-time setup per clone):**
    \`\`\`bash
    pre-commit install
    \`\`\`

3.  **Run Checks Manually:**
    * Format code: `ruff format .`
    * Lint code: `ruff check .`
    # --- SRC LAYOUT CHANGE: Updated mypy command ---
    * Run type checks: `mypy src tests`
    * Run tests: `pytest` (includes coverage report)

4.  **Making Commits:** When you run `git commit`, `pre-commit` will automatically run configured checks.

MD
create_file(File.join(project_dir, 'README.md'), readme_content)

# 3. .gitignore (Same as before)
gitignore_content = <<~GITIGNORE
# Python general
__pycache__/
*.py[cod]
*$py.class

# Build artifacts
build/
dist/
*.egg-info/
*.egg

# Virtual environment
.venv/
venv/
ENV/
env/
lib/
lib64/
include/
Scripts/
bin/

# Distribution / packaging
.Python
develop-eggs/
eggs/
sdist/
var/
*.egg-info/
.installed.cfg
*.manifest
*.spec

# PyInstaller
# *.out

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/

# Type checker cache
.mypy_cache/
.dmypy.json
dmypy.json

# Ruff cache
.ruff_cache/

# Jupyter Notebook
.ipynb_checkpoints

# VS Code specific
.vscode/

# PyCharm specific
# .idea/

# Mac specific
.DS_Store
GITIGNORE
create_file(File.join(project_dir, '.gitignore'), gitignore_content)

# --- SRC LAYOUT CHANGE: Files created in package_source_dir ---
# 4. package_name/__init__.py (Generic version)
init_content = <<~PY
# #{package_name}/__init__.py
"""Main package for #{project_name}."""
__version__ = "0.1.0"
PY
create_file(File.join(package_source_dir, '__init__.py'), init_content) # Use package_source_dir

# 5. package_name/core.py (Generic placeholder)
core_py_content = <<~PY
# #{package_name}/core.py
"""Core module for #{project_name}."""
def placeholder_function(x: int) -> int:
    """Placeholder function."""
    print("Running placeholder_function...")
    return x + 1
PY
create_file(File.join(package_source_dir, 'core.py'), core_py_content) # Use package_source_dir

# 6. tests/test_core.py (Generic placeholder test)
# --- SRC LAYOUT CHANGE: Import path remains the same due to editable install ---
test_core_py_content = <<~PY
# tests/test_core.py
"""Tests for the core module."""
import pytest # type: ignore
from #{package_name}.core import placeholder_function # Import should work if installed editable

def test_placeholder_function():
    """Test the placeholder function."""
    assert placeholder_function(1) == 2
PY
create_file(File.join(tests_dir, 'test_core.py'), test_core_py_content) # Tests still in tests_dir

# 7. .pre-commit-config.yaml (Same as before)
pre_commit_config_content = <<~YAML
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-added-large-files
-   repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.4.4
    hooks:
    -   id: ruff-format
    -   id: ruff
        args: [--fix, --exit-non-zero-on-fix]
# Optional mypy hook - may need 'files: ^src/' if uncommented
# -   repo: https://github.com/pre-commit/mirrors-mypy
#     rev: 'v1.10.0'
#     hooks:
#     -   id: mypy
YAML
create_file(File.join(project_dir, '.pre-commit-config.yaml'), pre_commit_config_content)


puts "\nProject '#{project_name}' scaffolded successfully in '#{project_dir}' (using src layout)!"
puts "\nNext steps (if not already in the directory):"
puts "1. cd \"#{project_dir}\""
puts "2. python3 -m venv .venv"
puts "3. source .venv/bin/activate"
puts "4. pip install -e .[dev]  # Installs package from 'src/' in editable mode"
puts "5. pre-commit install"
puts "6. # (Optional) Update author details and license in pyproject.toml"
puts "7. # Start developing in 'src/#{package_name}/core.py' and writing tests in 'tests/test_core.py'"
puts "8. # Manual checks: pytest, ruff check ., ruff format ., mypy src tests"