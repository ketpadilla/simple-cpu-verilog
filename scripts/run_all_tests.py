# scripts/run_all_tests.py
#
# Run All Verilog Testbenches
#
# Function:
#   Compiles and runs all Verilog testbenches in the tests/ directory.
#   Each testbench generates its own VCD and log file in the out/ directory.
#   This script reads each testbench log file and prints a combined summary.
#
# Output:
#   out/run_all_tests.log
#
# To run:
#   python scripts/run_all_tests.py


"""
@file run_all_tests.py
@brief Runs all Verilog testbenches and summarizes the results.

This script:
 - Creates the out/ directory if missing
 - Compiles each Verilog testbench using Icarus Verilog
 - Runs each compiled simulation using vvp
 - Reads each generated testbench log file
 - Extracts Total Tests, Passed, Failed, and Final Result
 - Prints a combined project-level summary
 - Saves the combined test runner output to out/run_all_tests.log
"""

from pathlib import Path
import subprocess
import re
import sys


ROOT_DIR = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT_DIR / "out"
RUNNER_LOG_PATH = OUT_DIR / "run_all_tests.log"


TESTBENCHES = [
    {
        "name": "ALU",
        "sources": [
            "src/alu.v",
            "tests/alu_tb.v",
        ],
        "output": "out/alu_tb.vvp",
        "log": "out/alu_tb.log",
    },
    {
        "name": "8-Bit Register",
        "sources": [
            "src/register_8bit.v",
            "tests/register_8bit_tb.v",
        ],
        "output": "out/register_8bit_tb.vvp",
        "log": "out/register_8bit_tb.log",
    },
    {
        "name": "Instruction Register",
        "sources": [
            "src/instruction_register.v",
            "tests/instruction_register_tb.v",
        ],
        "output": "out/instruction_register_tb.vvp",
        "log": "out/instruction_register_tb.log",
    },
    {
        "name": "Program Counter",
        "sources": [
            "src/program_counter.v",
            "tests/program_counter_tb.v",
        ],
        "output": "out/program_counter_tb.vvp",
        "log": "out/program_counter_tb.log",
    },
    {
        "name": "Instruction Memory",
        "sources": [
            "src/instruction_memory.v",
            "tests/instruction_memory_tb.v",
        ],
        "output": "out/instruction_memory_tb.vvp",
        "log": "out/instruction_memory_tb.log",
    },
    {
        "name": "Datapath",
        "sources": [
            "src/register_8bit.v",
            "src/alu.v",
            "src/datapath.v",
            "tests/datapath_tb.v",
        ],
        "output": "out/datapath_tb.vvp",
        "log": "out/datapath_tb.log",
    },
    {
        "name": "Controlpath",
        "sources": [
            "src/controlpath.v",
            "tests/controlpath_tb.v",
        ],
        "output": "out/controlpath_tb.vvp",
        "log": "out/controlpath_tb.log",
    },
    {
        "name": "Top-Level CPU",
        "sources": [
            "src/register_8bit.v",
            "src/alu.v",
            "src/datapath.v",
            "src/instruction_memory.v",
            "src/instruction_register.v",
            "src/program_counter.v",
            "src/controlpath.v",
            "src/top.v",
            "tests/top_tb.v",
        ],
        "output": "out/top_tb.vvp",
        "log": "out/top_tb.log",
    },
]


class Logger:
    """Prints messages to the terminal and writes them to a log file."""

    def __init__(self, log_path: Path):
        self.log_path = log_path
        self.file = log_path.open("w", encoding="utf-8")

    def write(self, message: str = "") -> None:
        print(message)
        self.file.write(message + "\n")
        self.file.flush()

    def close(self) -> None:
        self.file.close()


def run_command(command: list[str]) -> tuple[int, str]:
    """Run a command and return exit code plus combined output."""
    try:
        completed = subprocess.run(
            command,
            cwd=ROOT_DIR,
            text=True,
            capture_output=True,
            check=False,
        )

        output = completed.stdout + completed.stderr
        return completed.returncode, output

    except FileNotFoundError:
        return 1, f"Command not found: {command[0]}"


def parse_log_file(log_path: Path) -> dict:
    """Extract test summary values from a testbench log file."""
    if not log_path.exists():
        return {
            "total": 0,
            "passed": 0,
            "failed": 1,
            "final_result": "LOG FILE NOT FOUND",
        }

    content = log_path.read_text(errors="replace")

    total_match = re.search(r"Total Tests\s*:\s*(\d+)", content)
    passed_match = re.search(r"Passed\s*:\s*(\d+)", content)
    failed_match = re.search(r"Failed\s*:\s*(\d+)", content)
    result_match = re.search(r"Final Result:\s*(.+)", content)

    total = int(total_match.group(1)) if total_match else 0
    passed = int(passed_match.group(1)) if passed_match else 0
    failed = int(failed_match.group(1)) if failed_match else 1
    final_result = result_match.group(1).strip() if result_match else "UNKNOWN"

    return {
        "total": total,
        "passed": passed,
        "failed": failed,
        "final_result": final_result,
    }


def separator(logger: Logger) -> None:
    logger.write("=" * 70)


def main() -> int:
    OUT_DIR.mkdir(exist_ok=True)

    logger = Logger(RUNNER_LOG_PATH)

    try:
        separator(logger)
        logger.write("Simple CPU Verilog Test Runner")
        separator(logger)
        logger.write(f"Project Root : {ROOT_DIR}")
        logger.write(f"Output Folder: {OUT_DIR}")
        logger.write(f"Runner Log   : {RUNNER_LOG_PATH}")
        separator(logger)
        logger.write()

        overall_total = 0
        overall_passed = 0
        overall_failed = 0
        failed_testbenches = []

        results = []

        for testbench in TESTBENCHES:
            name = testbench["name"]
            sources = testbench["sources"]
            output_file = testbench["output"]
            log_file = testbench["log"]

            compile_command = ["iverilog", "-o", output_file] + sources
            simulation_command = ["vvp", output_file]

            separator(logger)
            logger.write(f"Running Testbench: {name}")
            separator(logger)

            logger.write("Compile Command:")
            logger.write(" ".join(compile_command))

            compile_code, compile_output = run_command(compile_command)

            if compile_code != 0:
                logger.write("[COMPILE FAIL]")
                logger.write(compile_output)

                results.append({
                    "name": name,
                    "status": "COMPILE FAIL",
                    "total": 0,
                    "passed": 0,
                    "failed": 1,
                    "log": log_file,
                })

                overall_failed += 1
                failed_testbenches.append(name)
                logger.write()
                continue

            logger.write("[COMPILE PASS]")
            logger.write()

            logger.write("Simulation Command:")
            logger.write(" ".join(simulation_command))

            simulation_code, simulation_output = run_command(simulation_command)

            if simulation_code != 0:
                logger.write("[SIMULATION FAIL]")
                logger.write(simulation_output)

                results.append({
                    "name": name,
                    "status": "SIMULATION FAIL",
                    "total": 0,
                    "passed": 0,
                    "failed": 1,
                    "log": log_file,
                })

                overall_failed += 1
                failed_testbenches.append(name)
                logger.write()
                continue

            logger.write("[SIMULATION PASS]")

            log_summary = parse_log_file(ROOT_DIR / log_file)

            total = log_summary["total"]
            passed = log_summary["passed"]
            failed = log_summary["failed"]
            final_result = log_summary["final_result"]

            status = "PASS" if failed == 0 and "ALL TESTS PASSED" in final_result else "FAIL"

            results.append({
                "name": name,
                "status": status,
                "total": total,
                "passed": passed,
                "failed": failed,
                "log": log_file,
            })

            overall_total += total
            overall_passed += passed
            overall_failed += failed

            if status != "PASS":
                failed_testbenches.append(name)

            logger.write()
            logger.write("Testbench Summary:")
            logger.write(f"  Total Tests : {total}")
            logger.write(f"  Passed      : {passed}")
            logger.write(f"  Failed      : {failed}")
            logger.write(f"  Final Result: {final_result}")
            logger.write(f"  Log File    : {log_file}")
            logger.write()

        separator(logger)
        logger.write("Combined Test Summary")
        separator(logger)

        for result in results:
            logger.write(
                f"{result['name']:<24} "
                f"{result['status']:<15} "
                f"Total={result['total']:<3} "
                f"Passed={result['passed']:<3} "
                f"Failed={result['failed']:<3} "
                f"Log={result['log']}"
            )

        separator(logger)
        logger.write(f"Overall Total Tests : {overall_total}")
        logger.write(f"Overall Passed      : {overall_passed}")
        logger.write(f"Overall Failed      : {overall_failed}")

        if overall_failed == 0 and not failed_testbenches:
            logger.write("Final Result        : ALL TESTBENCHES PASSED")
            logger.write(f"Runner Log Saved To : {RUNNER_LOG_PATH}")
            separator(logger)
            return 0

        logger.write("Final Result        : SOME TESTBENCHES FAILED")
        logger.write("Failed Testbenches  : " + ", ".join(failed_testbenches))
        logger.write(f"Runner Log Saved To : {RUNNER_LOG_PATH}")
        separator(logger)
        return 1

    finally:
        logger.close()


if __name__ == "__main__":
    sys.exit(main())