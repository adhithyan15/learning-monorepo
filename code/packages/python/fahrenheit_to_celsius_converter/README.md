# fahrenheit_to_celsius_converter

A brief description of your project.

## Installation

```bash
# Navigate to the project directory first if needed:
# cd path/to/fahrenheit_to_celsius_converter

# Create and activate virtual environment (Recommended)
python3 -m venv .venv
source .venv/bin/activate  # macOS/Linux
# ..venvScriptsctivate  # Windows

# Install the package in editable mode with development dependencies
# Editable install makes the code in src/ available for import
pip install -e .[dev]
```

## Usage

```python
# TODO: Add usage examples here
# Example (assuming package is installed):
# from fahrenheit_to_celsius_converter import placeholder_function
#
# result = placeholder_function(1)
# print(result)
```

## Development Workflow

This project uses a `src` layout, `ruff` for linting/formatting, and `pytest` for testing. `pre-commit` is configured to run checks automatically.

1.  **Set up Environment (if not done during Installation):**
    ```bash
    cd path/to/fahrenheit_to_celsius_converter
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -e .[dev]
    ```

2.  **Install Git Hooks (One-time setup per clone):**
    ```bash
    pre-commit install
    ```

3.  **Run Checks Manually:**
    * Format code: `ruff format .`
    * Lint code: `ruff check .`
    # --- SRC LAYOUT CHANGE: Updated mypy command ---
    * Run type checks: `mypy src tests`
    * Run tests: `pytest` (includes coverage report)

4.  **Making Commits:** When you run `git commit`, `pre-commit` will automatically run configured checks.

