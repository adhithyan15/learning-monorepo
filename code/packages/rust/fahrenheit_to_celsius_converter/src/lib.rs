/// Convert Fahrenheit to Celsius.
///
/// # Formula
/// `(f - 32.0) * 5.0 / 9.0`
#[no_mangle]
pub extern "C" fn fahrenheit_to_celsius(f: f64) -> f64 {
    (f - 32.0) * 5.0 / 9.0
}

#[cfg(test)]
mod tests;