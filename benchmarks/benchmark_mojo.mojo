"""Benchmark mojo-ini performance.

Measures parse and write performance with various input sizes.
Compare results with benchmarks/compare_python.py for baseline.
"""

from time.time import perf_counter_ns
from ini import parse, to_ini


fn benchmark_parse(content: String, iterations: Int) raises -> Float64:
    """Benchmark parsing performance."""
    var start = perf_counter_ns()

    for _ in range(iterations):
        var _ = parse(content)

    var end = perf_counter_ns()
    var duration_ns = Float64(end - start)
    var duration_us = duration_ns / 1000.0
    var per_iteration_us = duration_us / Float64(iterations)

    return per_iteration_us


fn benchmark_write(data: Dict[String, Dict[String, String]], iterations: Int) raises -> Float64:
    """Benchmark writing performance."""
    var start = perf_counter_ns()

    for _ in range(iterations):
        var _ = to_ini(data)

    var end = perf_counter_ns()
    var duration_ns = Float64(end - start)
    var duration_us = duration_ns / 1000.0
    var per_iteration_us = duration_us / Float64(iterations)

    return per_iteration_us


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
    print()

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
    var small_parse_time = benchmark_parse(small_content, small_iterations)
    print("Parse:  " + String(small_parse_time) + " μs per operation")
    print("        " + String(Int(1_000_000.0 / small_parse_time)) + " operations/second")

    # Write test (parse again to get fresh data)
    var small_data_for_write = parse(small_content)
    var small_write_time = benchmark_write(small_data_for_write^, small_iterations)
    print("Write:  " + String(small_write_time) + " μs per operation")
    print("        " + String(Int(1_000_000.0 / small_write_time)) + " operations/second")
    print()

    # Test 2: Medium config (10 sections, 10 keys each)
    print("Test 2: Medium Config (10 sections, 10 keys each)")
    print("-" * 70)

    var medium_data = create_test_data(10, 10)
    var medium_content = to_ini(medium_data)

    var medium_iterations = 5000
    var medium_parse_time = benchmark_parse(medium_content, medium_iterations)
    print("Parse:  " + String(medium_parse_time) + " μs per operation")
    print("        " + String(Int(1_000_000.0 / medium_parse_time)) + " operations/second")

    var medium_data_copy = create_test_data(10, 10)
    var medium_write_time = benchmark_write(medium_data_copy^, medium_iterations)
    print("Write:  " + String(medium_write_time) + " μs per operation")
    print("        " + String(Int(1_000_000.0 / medium_write_time)) + " operations/second")
    print()

    # Test 3: Large config (50 sections, 20 keys each)
    print("Test 3: Large Config (50 sections, 20 keys each)")
    print("-" * 70)

    var large_data = create_test_data(50, 20)
    var large_content = to_ini(large_data)

    var large_iterations = 1000
    var large_parse_time = benchmark_parse(large_content, large_iterations)
    print("Parse:  " + String(large_parse_time) + " μs per operation")
    print("        " + String(Int(1_000_000.0 / large_parse_time)) + " operations/second")

    var large_data_copy = create_test_data(50, 20)
    var large_write_time = benchmark_write(large_data_copy^, large_iterations)
    print("Write:  " + String(large_write_time) + " μs per operation")
    print("        " + String(Int(1_000_000.0 / large_write_time)) + " operations/second")
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
    var multiline_time = benchmark_parse(multiline_content, multiline_iterations)
    print("Parse:  " + String(multiline_time) + " μs per operation")
    print("        " + String(Int(1_000_000.0 / multiline_time)) + " operations/second")
    print()

    print("=" * 70)
    print("Benchmark Complete")
    print()
    print("Summary:")
    print("- Small config:  ~" + String(Int(small_parse_time)) + " μs parse, ~" + String(Int(small_write_time)) + " μs write")
    print("- Medium config: ~" + String(Int(medium_parse_time)) + " μs parse, ~" + String(Int(medium_write_time)) + " μs write")
    print("- Large config:  ~" + String(Int(large_parse_time)) + " μs parse, ~" + String(Int(large_write_time)) + " μs write")
    print()
    print("Compare with Python: pixi run benchmark-python")
