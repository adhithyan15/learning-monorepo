# fahrenheit_to_celsius_converter/__init__.py

# Import functions from the core module to expose them at the package level
from .core import fahrenheit_to_celsius

"""Main package for fahrenheit_to_celsius_converter."""
__version__ = "0.1.0"

__all__ = [
    "fahrenheit_to_celsius",
    "__version__",
]
