from __future__ import annotations
from collections import defaultdict
import csv
import datetime
import os
import sys
import re

# csv files argument needs to be provided
PATH_TO_CSV_FILES = sys.argv[1]
OUTPUR_PATH_FOR_MD = sys.argv[2]
BENCH_CONFIG = sys.argv[3] if len(sys.argv) > 3 else "Unknown"

# pattern: benchmark-tier{tier}-opt{opt}-{target}.csv
# e.g. deltablue-tier0-opt2-jvm.csv
CSV_FILE_NAME = re.compile(r"(\w+)-tier(\d+)-opt(\d+)-(.*)\.csv")
DATA = defaultdict(
    lambda: defaultdict(dict)
)  # (benchmark, target) -> opt -> tier -> Runtime mean + other info


class BenchmarkData:
    def __init__(self, mean, stddev, user, system):
        self.mean = float(mean) * 1000
        self.stddev = float(stddev) * 1000
        self.user = float(user) * 1000
        self.system = float(system) * 1000

    def __repr__(self):
        return f"Data: {self.mean}"


def get_csv_data(path: str) -> BenchmarkData:
    with open(path, "r") as inp:
        csv_reader = csv.DictReader(inp)
        for row in csv_reader:
            return BenchmarkData(
                row["mean"],
                row["stddev"],
                row["user"],
                row["system"],
            )


def main():
    # Read benchmark configuration
    benchmark_config = {}
    if os.path.isfile(BENCH_CONFIG):
        with open(BENCH_CONFIG, "r") as f:
            reader = csv.DictReader(f)
            for row in reader:
                benchmark_config[row["benchmark"]] = {
                    "files": row["files"],
                    "runs": row["runs"]
                }

    # Get all the necessary data from the csv files
    for entry in os.listdir(PATH_TO_CSV_FILES):
        csv_file_path = os.path.join(PATH_TO_CSV_FILES, entry)
        if os.path.isfile(csv_file_path) and csv_file_path.endswith(".csv"):
            match = CSV_FILE_NAME.match(os.path.basename(csv_file_path))
            bench, tier, opt, target = match.groups()
            DATA[(bench, target)][int(opt)][int(tier)] = get_csv_data(csv_file_path)

    output = []
    # Collect all unique tiers, opts, targets, and benchmarks
    all_tiers = sorted(
        {
            tier
            for _, tdata in DATA.items()
            for odata in tdata.values()
            for tier in odata
        }
    )
    all_opts = sorted({opt for _, tdata in DATA.items() for opt in tdata})
    all_targets = sorted({target for _, target in DATA.keys()})
    all_benchmarks = sorted({bench for bench, _ in DATA.keys()})

    # Organize data by target -> opt -> benchmark -> tier
    for target in all_targets:
        output.append(f"# {target}\n")

        for opt in all_opts:
            output.append(f"## -O{opt}\n")

            # Calculate column widths for alignment
            # First, collect all data for this target/opt combination
            table_data = []
            for bench in all_benchmarks:
                if (bench, target) in DATA:
                    row = [bench]
                    opt_data = DATA[(bench, target)]
                    for tier in all_tiers:
                        entry = opt_data.get(opt, {}).get(tier)
                        if entry:
                            cell = f"{entry.mean:.2f}ms"
                        else:
                            cell = "–"
                        row.append(cell)
                    table_data.append(row)

            # Calculate max width for each column
            col_widths = [len("Benchmark")]  # Start with header width
            for tier in all_tiers:
                col_widths.append(len(f"tier{tier}"))

            for row in table_data:
                for i, cell in enumerate(row):
                    col_widths[i] = max(col_widths[i], len(cell))

            # Create table header with padding
            header_cells = ["Benchmark"] + [f"tier{t}" for t in all_tiers]
            header = "| " + " | ".join(header_cells[i].ljust(col_widths[i]) for i in range(len(header_cells))) + " |"

            # Left align first column (benchmark), right align remaining columns (times)
            sep = "|:" + "-" * (col_widths[0] + 1) + "|" + "|".join("-" * (col_widths[i] + 1) + ":" for i in range(1, len(col_widths)))

            output.append(header)
            output.append(sep)

            # Create rows with padding
            for row in table_data:
                formatted_row = [row[0].ljust(col_widths[0])]  # Left align benchmark name
                for i in range(1, len(row)):
                    formatted_row.append(row[i].rjust(col_widths[i]))  # Right align times
                output.append("| " + " | ".join(formatted_row) + " |")
            output.append("\n")

    # Add configuration section
    output.append("---\n")
    output.append("# Configuration\n")

    output.append(f"* `BENCH_TARGETS`: {', '.join(all_targets)}\n")
    output.append(f"* `BENCH_TIERS`: {', '.join(str(t) for t in all_tiers)}\n")
    output.append(f"* `BENCH_OPT_LEVELS`: {', '.join(str(o) for o in all_opts)}\n")

    if benchmark_config:
        output.append(f"\n## Benchmark Runs (`{BENCH_CONFIG}`)\n")
        output.append("| Benchmark | Files | Runs |")
        output.append("|:----------|:------|-----:|")
        for bench in all_benchmarks:
            if bench in benchmark_config:
                files = benchmark_config[bench]["files"]
                runs = benchmark_config[bench]["runs"]
                output.append(f"| {bench} | `{files}` | {runs} |")

    # Write Markdown
    date = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    file_name = f"{OUTPUR_PATH_FOR_MD}/benchmark-results-{date}.md"
    with open(file_name, "w") as f:
        f.write("\n".join(output))


if __name__ == "__main__":
    main()
    print(f"Done: .md file in {OUTPUR_PATH_FOR_MD}")
