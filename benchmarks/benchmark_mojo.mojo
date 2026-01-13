"""Benchmark mojo-ini performance.

Measures parse and write performance with various input sizes.
Compare results with benchmarks/compare_python.py for baseline.
"""

from time.time import perf_counter_ns
from ini import parse, to_ini
from math import sqrt


fn benchmark_parse(content: String, warmup_iterations: Int, iterations: Int, trials: Int) raises -> List[Float64]:
    """Benchmark parsing performance with multiple trials.

    Args:
        content: INI content to parse.
        warmup_iterations: Number of warmup iterations (to prime JIT).
        iterations: Number of iterations per trial.
        trials: Number of trials to run.

    Returns:
        List of per-iteration times (μs) for each trial.
    """
    # Warmup: prime JIT compiler and caches
    for _ in range(warmup_iterations):
        var _ = parse(content)

    # Run multiple trials
    var results = List[Float64]()
    for _ in range(trials):
        var start = perf_counter_ns()

        for _ in range(iterations):
            var _ = parse(content)

        var end = perf_counter_ns()
        var duration_ns = Float64(end - start)
        var duration_us = duration_ns / 1000.0
        var per_iteration_us = duration_us / Float64(iterations)
        results.append(per_iteration_us)

    return results^


fn benchmark_write(data: Dict[String, Dict[String, String]], warmup_iterations: Int, iterations: Int, trials: Int) raises -> List[Float64]:
    """Benchmark writing performance with multiple trials.

    Args:
        data: Data structure to write.
        warmup_iterations: Number of warmup iterations (to prime JIT).
        iterations: Number of iterations per trial.
        trials: Number of trials to run.

    Returns:
        List of per-iteration times (μs) for each trial.
    """
    # Warmup
    for _ in range(warmup_iterations):
        var _ = to_ini(data)

    # Run multiple trials
    var results = List[Float64]()
    for _ in range(trials):
        var start = perf_counter_ns()

        for _ in range(iterations):
            var _ = to_ini(data)

        var end = perf_counter_ns()
        var duration_ns = Float64(end - start)
        var duration_us = duration_ns / 1000.0
        var per_iteration_us = duration_us / Float64(iterations)
        results.append(per_iteration_us)

    return results^


struct BenchmarkStats:
    var min_val: Float64
    var max_val: Float64
    var mean: Float64
    var stddev: Float64

    fn __init__(out self, min_val: Float64, max_val: Float64, mean: Float64, stddev: Float64):
        self.min_val = min_val
        self.max_val = max_val
        self.mean = mean
        self.stddev = stddev


fn calculate_stats(results: List[Float64]) -> BenchmarkStats:
    """Calculate min, max, mean, and standard deviation.

    Returns:
        BenchmarkStats struct containing min, max, mean, and stddev.
    """
    var n = len(results)
    if n == 0:
        return BenchmarkStats(0.0, 0.0, 0.0, 0.0)

    # Find min and max
    var min_val = results[0]
    var max_val = results[0]
    var sum_val = 0.0

    for i in range(n):
        var val = results[i]
        if val < min_val:
            min_val = val
        if val > max_val:
            max_val = val
        sum_val += val

    var mean = sum_val / Float64(n)

    # Calculate standard deviation
    var sum_squared_diff = 0.0
    for i in range(n):
        var diff = results[i] - mean
        sum_squared_diff += diff * diff

    var variance = sum_squared_diff / Float64(n)
    var stddev = sqrt(variance)

    return BenchmarkStats(min_val, max_val, mean, stddev)


fn print_stats(label: String, results: List[Float64]):
    """Print benchmark statistics."""
    var stats = calculate_stats(results)
    var min_time = stats.min_val
    var max_time = stats.max_val
    var mean_time = stats.mean
    var stddev_val = stats.stddev

    print(label + ":  " + String(mean_time) + " μs per operation (±" + String(stddev_val) + " μs)")
    print("        min: " + String(min_time) + " μs, max: " + String(max_time) + " μs")
    print("        " + String(Int(1_000_000.0 / mean_time)) + " operations/second")


fn create_test_data(sections: Int, keys_per_section: Int) raises -> Dict[String, Dict[String, String]]:
    """Create test data with specified size."""
    var data = Dict[String, Dict[String, String]]()

    for s in range(sections):
        var section_name = "Section" + String(s)
        data[section_name] = Dict[String, String]()

        for k in range(keys_per_section):
            var key = "key" + String(k)
            var value = "value" + String(k) + "_for_section_" + String(s)
            data[section_name][key] = value

    return data^


fn main() raises:
    print("=" * 70)
    print("mojo-ini Performance Benchmark")
    print("=" * 70)
    print("With warmup and 5 trials per test for statistical accuracy")
    print()

    var warmup = 100
    var trials = 5

    # Test 1: Small config (similar to sample.ini)
    print("Test 1: Small Config (4 sections, 3-4 keys each)")
    print("-" * 70)

    var small_content = """[Database]
host = localhost
port = 5432
user = admin

[Server]
debug = true
timeout = 30
host = 0.0.0.0

[Logging]
level = INFO
file = /var/log/app.log

[Features]
enable_api = true
enable_web = true
enable_admin = false"""

    var small_iterations = 10000
    var small_parse_results = benchmark_parse(small_content, warmup, small_iterations, trials)
    print_stats("Parse", small_parse_results)

    # Write test (parse again to get fresh data)
    var small_data_for_write = parse(small_content)
    var small_write_results = benchmark_write(small_data_for_write^, warmup, small_iterations, trials)
    print_stats("Write", small_write_results)
    print()

    # Test 2: Medium config (10 sections, 10 keys each)
    print("Test 2: Medium Config (10 sections, 10 keys each)")
    print("-" * 70)

    var medium_data = create_test_data(10, 10)
    var medium_content = to_ini(medium_data)

    var medium_iterations = 5000
    var medium_parse_results = benchmark_parse(medium_content, warmup, medium_iterations, trials)
    print_stats("Parse", medium_parse_results)

    var medium_data_copy = create_test_data(10, 10)
    var medium_write_results = benchmark_write(medium_data_copy^, warmup, medium_iterations, trials)
    print_stats("Write", medium_write_results)
    print()

    # Test 3: Large config (50 sections, 20 keys each)
    print("Test 3: Large Config (50 sections, 20 keys each)")
    print("-" * 70)

    var large_data = create_test_data(50, 20)
    var large_content = to_ini(large_data)

    var large_iterations = 1000
    var large_parse_results = benchmark_parse(large_content, warmup, large_iterations, trials)
    print_stats("Parse", large_parse_results)

    var large_data_copy = create_test_data(50, 20)
    var large_write_results = benchmark_write(large_data_copy^, warmup, large_iterations, trials)
    print_stats("Write", large_write_results)
    print()

    # Test 4: Multiline values
    print("Test 4: Multiline Values")
    print("-" * 70)

    var multiline_content = """[Database]
connection_string = postgresql://user:pass@localhost:5432/db
    ?sslmode=require
    &connect_timeout=10
    &application_name=myapp

[Email]
recipients = user1@example.com,
    user2@example.com,
    user3@example.com,
    user4@example.com

[Documentation]
description = This is a long description
    that spans multiple lines
    with detailed information
    about the configuration"""

    var multiline_iterations = 10000
    var multiline_results = benchmark_parse(multiline_content, warmup, multiline_iterations, trials)
    print_stats("Parse", multiline_results)
    print()

    print("=" * 70)
    print("Benchmark Complete")
    print()
    print("Summary (mean times):")
    var small_parse_mean = calculate_stats(small_parse_results).mean
    var small_write_mean = calculate_stats(small_write_results).mean
    var medium_parse_mean = calculate_stats(medium_parse_results).mean
    var medium_write_mean = calculate_stats(medium_write_results).mean
    var large_parse_mean = calculate_stats(large_parse_results).mean
    var large_write_mean = calculate_stats(large_write_results).mean

    print("- Small config:  ~" + String(Int(small_parse_mean)) + " μs parse, ~" + String(Int(small_write_mean)) + " μs write")
    print("- Medium config: ~" + String(Int(medium_parse_mean)) + " μs parse, ~" + String(Int(medium_write_mean)) + " μs write")
    print("- Large config:  ~" + String(Int(large_parse_mean)) + " μs parse, ~" + String(Int(large_write_mean)) + " μs write")
    print()
    print("Compare with Python: pixi run benchmark-python")
