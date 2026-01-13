#!/usr/bin/env python3
"""Comparative benchmarks: mojo-ini vs Python configparser.

Compares parsing and writing performance between mojo-ini and Python's
standard library configparser implementation.

Run with: pixi run benchmark-python
"""

import sys
import time
import configparser
import io
from pathlib import Path

# Import benchmark utilities (from mojo-toml, reused here)
sys.path.insert(0, str(Path(__file__).parent))


# Test documents
SIMPLE_INI = """[Database]
host = localhost
port = 5432
user = admin

[Server]
debug = true
timeout = 30
"""

MULTIPLE_SECTIONS = """[Application]
name = MyApp
version = 1.0.0

[Window]
width = 1024
height = 768

[Database]
server = localhost
port = 5432

[Logging]
level = INFO
file = /var/log/app.log
"""

LARGE_INI = """[Section1]
key1 = value1
key2 = value2
key3 = value3
key4 = value4
key5 = value5

[Section2]
key1 = value1
key2 = value2
key3 = value3
key4 = value4
key5 = value5

[Section3]
key1 = value1
key2 = value2
key3 = value3
key4 = value4
key5 = value5
"""


def benchmark_python_parse(ini_content: str, iterations: int = 1000) -> tuple[float, int]:
    """Benchmark Python's configparser parsing. Returns (elapsed_time, iterations)."""
    start = time.perf_counter()
    for _ in range(iterations):
        config = configparser.ConfigParser()
        config.read_string(ini_content)
    elapsed = time.perf_counter() - start
    return elapsed, iterations


def benchmark_python_write(config: configparser.ConfigParser, iterations: int = 500) -> tuple[float, int]:
    """Benchmark Python's configparser writing. Returns (elapsed_time, iterations)."""
    start = time.perf_counter()
    for _ in range(iterations):
        output = io.StringIO()
        config.write(output)
        _ = output.getvalue()
    elapsed = time.perf_counter() - start
    return elapsed, iterations


def format_time(seconds: float) -> str:
    """Format time in appropriate units."""
    if seconds < 0.001:
        return f"{seconds * 1_000_000:.0f} μs"
    elif seconds < 1.0:
        return f"{seconds * 1_000:.1f} ms"
    else:
        return f"{seconds:.2f} s"


def format_rate(rate: float) -> str:
    """Format rate with thousands separator."""
    if rate >= 1_000_000:
        return f"{rate / 1_000_000:.2f}M/sec"
    elif rate >= 1_000:
        return f"{rate / 1_000:.1f}K/sec"
    else:
        return f"{rate:.0f}/sec"


def run_parse_comparison(name: str, ini_content: str, iterations: int = 1000):
    """Run and display Python parsing benchmark."""
    print(f"\n{name}:")

    py_time, py_iters = benchmark_python_parse(ini_content, iterations)
    py_rate = py_iters / py_time
    py_avg = py_time / py_iters

    print(f"  Python (configparser):  {format_time(py_avg)} per parse  |  {format_rate(py_rate)}")


def run_write_comparison(name: str, config: configparser.ConfigParser, iterations: int = 500):
    """Run and display Python writing benchmark."""
    print(f"\n{name}:")

    py_time, py_iters = benchmark_python_write(config, iterations)
    py_rate = py_iters / py_time
    py_avg = py_time / py_iters

    print(f"  Python (configparser):  {format_time(py_avg)} per write  |  {format_rate(py_rate)}")


def main():
    """Run all comparison benchmarks."""
    print("=" * 70)
    print("Python INI Baseline Benchmarks (configparser)")
    print("=" * 70)

    print("\nThese establish baseline performance for comparison with mojo-ini.")
    print("Run 'pixi run benchmark-mojo' to see mojo-ini performance.")

    # Parsing benchmarks
    print("\n\nParsing Benchmarks (configparser.read_string()):")
    print("=" * 70)

    run_parse_comparison("Simple INI (2 sections, 6 keys)", SIMPLE_INI, 5000)
    run_parse_comparison("Multiple sections (4 sections, 10 keys)", MULTIPLE_SECTIONS, 2000)
    run_parse_comparison("Large INI (3 sections, 15 keys)", LARGE_INI, 2000)

    # Writing benchmarks
    print("\n\nWriting Benchmarks (configparser.write()):")
    print("=" * 70)

    # Simple config
    simple_config = configparser.ConfigParser()
    simple_config.read_string(SIMPLE_INI)
    run_write_comparison("Simple INI (2 sections, 6 keys)", simple_config, 3000)

    # Multiple sections
    multi_config = configparser.ConfigParser()
    multi_config.read_string(MULTIPLE_SECTIONS)
    run_write_comparison("Multiple sections (4 sections, 10 keys)", multi_config, 2000)

    print("\n" + "=" * 70)
    print("Benchmark Complete")
    print("=" * 70)
    print("\nNOTE: Python configparser is implemented in C for performance.")
    print("mojo-ini aims to be competitive for typical config file sizes.")


if __name__ == "__main__":
    main()
