from __future__ import annotations
from collections import defaultdict
import csv
import os
import sys
import re

# csv files argument needs to be provided
PATH_TO_CSV_FILES = sys.argv[1]

# pattern: benchmark-tier{tier}-opt{opt}-{target}.csv
# e.g. deltablue-tier0-opt2-jvm.csv
CSV_FILE_NAME = re.compile(r"(\w+)-tier(\d+)-opt(\d+)-(.*)\.csv")
DATA = defaultdict(
    lambda: defaultdict(dict)
)  # (benchmark, target) -> opt -> tier -> Runtime mean + other info


class BenchmarkData:
    def __init__(self, mean, stddev, user, system, min, max):
        self.mean = float(mean) * 1000
        self.stddev = float(stddev) * 1000
        self.user = float(user) * 1000
        self.system = float(system) * 1000
        self.min = float(min) * 1000
        self.max = float(max) * 1000

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
                row["min"],
                row["max"],
            )


def main():
    # Get all the necessary data from the csv files
    for entry in os.listdir(PATH_TO_CSV_FILES):
        csv_file_path = os.path.join(PATH_TO_CSV_FILES, entry)
        if os.path.isfile(csv_file_path) and csv_file_path.endswith(".csv"):
            match = CSV_FILE_NAME.match(os.path.basename(csv_file_path))
            bench, tier, opt, target = match.groups()
            DATA[(bench, target)][int(opt)][int(tier)] = get_csv_data(csv_file_path)

    output = []
    # Collect all unique tiers and opts
    all_tiers = sorted(
        {
            tier
            for _, tdata in DATA.items()
            for odata in tdata.values()
            for tier in odata
        }
    )
    all_opts = sorted({opt for _, tdata in DATA.items() for opt in tdata})

    for (bench, target), opt_data in sorted(DATA.items()):
        output.append(f"## Benchmark: `{bench}` ({target})\n")
        header = "| Opt/Tier | " + " | ".join(f"Tier {t}" for t in all_tiers) + " |"
        sep = "|" + "-----------|" * (len(all_tiers) + 1)
        output.append(header)
        output.append(sep)

        for opt in all_opts:
            row = [f"Opt-{opt}"]
            for tier in all_tiers:
                entry = opt_data.get(opt, {}).get(tier)
                if entry:
                    cell = create_div_element(entry)
                else:
                    cell = "<span>–</span>"
                row.append(cell)
            output.append("| " + " | ".join(row) + " |")
        output.append("\n")

    # Write Markdown
    with open(f"{PATH_TO_CSV_FILES}/benchmark-results.md", "w") as f:
        f.write("\n".join(output))


def create_div_element(entry: BenchmarkData):
    return (
        f"<div style='font-size:85%; line-height:1.3;'>"
        f"<small>Mean: </small>"
        f"<span style='color:#65a765; font-weight:600;'>{entry.mean:.2f}ms"
        f" ± {entry.stddev:.2f}ms</span><br> "
        f"<small>Range: </small>"
        f"<span style='color:#4B77BE;font-size:85%;'>"
        f"{entry.min:.1f} .. {entry.max:.1f} ms</span><br>"
        f"<span style='color:#9ca3af; font-size:80%;'>"
        f"user {entry.user:.1f} ms, sys {entry.system:.1f} ms</span></div>"
    )


if __name__ == "__main__":
    main()
    print(f"Done: .md file in {PATH_TO_CSV_FILES}")
