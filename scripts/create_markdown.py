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

# pattern: benchmark-tier{tier}-opt{opt}[-wopt{wopt}-mode{mode}]-{target}.csv
# e.g. deltablue-tier0-opt2-jvm.csv, sieve-tier1-opt2-wopt2-modejit-wasm-wave.csv
# The wopt (wasm-opt level)/mode segments only appear for wasm-wave (always
# together); every other target has implicit wopt/mode of "none".
CSV_FILE_NAME = re.compile(r"(\w+)-tier(\d+)-opt(\d+)-(?:wopt(\w+)-mode(\w+)-)?(.*)\.csv")
DATA = defaultdict(
    lambda: defaultdict(dict)
)  # (benchmark, target, mode, wopt) -> opt -> tier -> Runtime mean + other info


class BenchmarkData:
    def __init__(self, mean, stddev, median, user, system, min_, max_):
        self.mean = float(mean) * 1000
        self.stddev = float(stddev) * 1000
        self.median = float(median) * 1000
        self.user = float(user) * 1000
        self.system = float(system) * 1000
        self.min = float(min_) * 1000
        self.max = float(max_) * 1000

    def __repr__(self):
        return f"Data: {self.mean}"


def get_csv_data(path: str) -> BenchmarkData:
    with open(path, "r") as inp:
        csv_reader = csv.DictReader(inp)
        for row in csv_reader:
            return BenchmarkData(
                row["mean"],
                row["stddev"],
                row["median"],
                row["user"],
                row["system"],
                row["min"],
                row["max"],
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
            bench, tier, opt, wopt, mode, target = match.groups()
            mode = mode if mode is not None else "none"
            wopt = wopt if wopt is not None else "none"
            DATA[(bench, target, mode, wopt)][int(opt)][int(tier)] = get_csv_data(csv_file_path)

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
    all_targets = sorted({target for _, target, _, _ in DATA.keys()})
    all_benchmarks = sorted({bench for bench, _, _, _ in DATA.keys()})

    # Organize data by target -> opt -> [wopt/mode ->] benchmark -> tier
    for target in all_targets:
        output.append(f"# {target}\n")

        # wopt (wasm-opt level) and mode only vary for wasm-wave; every other
        # target has the single implicit ("none", "none") pair, in which case
        # we don't bother annotating it.
        variants_for_target = sorted({
            (w, m) for b, t, m, w in DATA.keys() if t == target
        })
        single_variant = variants_for_target == [("none", "none")]

        for opt in all_opts:
            for wopt, mode in variants_for_target:
                if single_variant:
                    output.append(f"## -O{opt}\n")
                else:
                    output.append(f"## -O{opt} (wasm-opt=-O{wopt}, mode={mode})\n")

                # Calculate column widths for alignment
                # First, collect all data for this target/opt/wopt/mode combination
                table_data = []
                for bench in all_benchmarks:
                    key = (bench, target, mode, wopt)
                    if key in DATA:
                        row = [bench]
                        opt_data = DATA[key]
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

    # Build raw results CSV rows: one row per (target, wopt, mode, opt, tier, benchmark)
    # `wopt` (wasm-opt level) and `mode` (Wizard's execution mode) only apply
    # to wasm-wave; blank for every other target.
    csv_header = ["target", "wasm_opt_level", "mode", "opt", "tier", "benchmark",
                  "mean_ms", "stddev_ms", "median_ms", "user_ms", "system_ms",
                  "min_ms", "max_ms"]
    csv_rows = []
    for target in all_targets:
        variants_for_target = sorted({
            (w, m) for b, t, m, w in DATA.keys() if t == target
        })
        for wopt, mode in variants_for_target:
            wopt_label = "" if wopt == "none" else wopt
            mode_label = "" if mode == "none" else mode
            for opt in all_opts:
                for tier in all_tiers:
                    for bench in all_benchmarks:
                        entry = DATA.get((bench, target, mode, wopt), {}).get(opt, {}).get(tier)
                        if entry is None:
                            continue
                        csv_rows.append(
                            [target, wopt_label, mode_label, opt, tier, bench,
                             f"{entry.mean:.6f}", f"{entry.stddev:.6f}",
                             f"{entry.median:.6f}", f"{entry.user:.6f}",
                             f"{entry.system:.6f}", f"{entry.min:.6f}",
                             f"{entry.max:.6f}"]
                        )

    # Write Markdown and CSV, both as a timestamped copy and as a
    # "latest" copy that gets overwritten each run for easy lookup.
    date = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    md_text = "\n".join(output)
    for md_name in (f"benchmark-results-{date}.md", "benchmark-results-latest.md"):
        with open(f"{OUTPUR_PATH_FOR_MD}/{md_name}", "w") as f:
            f.write(md_text)

    for csv_name in (f"benchmark-results-{date}.csv", "benchmark-results-latest.csv"):
        with open(f"{OUTPUR_PATH_FOR_MD}/{csv_name}", "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(csv_header)
            writer.writerows(csv_rows)


if __name__ == "__main__":
    main()
    print(f"Done: .md file in {OUTPUR_PATH_FOR_MD}")
