use super::*;

#[test]
fn freezing_point() {
    let result = fahrenheit_to_celsius(32.0);
    assert!((result - 0.0).abs() < 1e-6);
}

#[test]
fn boiling_point() {
    let result = fahrenheit_to_celsius(212.0);
    assert!((result - 100.0).abs() < 1e-6);
}

#[test]
fn negative_same_value() {
    let result = fahrenheit_to_celsius(-40.0);
    assert!((result - -40.0).abs() < 1e-6);
}

#[test]
fn zero_fahrenheit() {
    let result = fahrenheit_to_celsius(0.0);
    assert!((result + 17.77777777777778).abs() < 1e-6);
}

#[test]
fn fractional_input() {
    let result = fahrenheit_to_celsius(98.6);
    assert!((result - 37.0).abs() < 1e-6);
}

#[test]
fn small_fractional_input() {
    let result = fahrenheit_to_celsius(32.000001);
    assert!(result.abs() < 1e-5);
}

#[test]
fn absolute_zero() {
    let result = fahrenheit_to_celsius(-459.67);
    assert!((result + 273.15).abs() < 1e-5);
}

#[test]
fn extremely_high_temp() {
    let result = fahrenheit_to_celsius(1000.0);
    assert!((result - 537.7777777777778).abs() < 1e-5);
}

#[test]
fn moderately_large_value() {
    let result = fahrenheit_to_celsius(451.0);
    assert!((result - 232.77777777777777).abs() < 1e-5);
}

#[test]
fn negative_fractional_input() {
    let result = fahrenheit_to_celsius(-58.3);
    assert!((result - -50.1666667).abs() < 1e-5);
}

#[test]
fn check_near_precision_boundary() {
    let result = fahrenheit_to_celsius(1e-8);
    let expected = (1e-8 - 32.0) * 5.0 / 9.0;
    assert!((result - expected).abs() < 1e-10);
}

#[test]
fn handles_large_inputs_safely() {
    assert!(fahrenheit_to_celsius(f64::MAX).is_infinite());
    assert!(fahrenheit_to_celsius(f64::MIN).is_infinite());
}

#[test]
fn does_not_panic_on_extremes() {
    let _ = fahrenheit_to_celsius(f64::MAX);
    let _ = fahrenheit_to_celsius(f64::MIN);
    let _ = fahrenheit_to_celsius(f64::INFINITY);
    let _ = fahrenheit_to_celsius(f64::NEG_INFINITY);
    let _ = fahrenheit_to_celsius(f64::NAN);
}