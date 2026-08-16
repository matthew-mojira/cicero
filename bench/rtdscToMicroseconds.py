# Example:
#   python rdtscToMicroseconds.py -d results/functionCalls/rtdsc/noCache
#       -f 2.7 -c 3,4,5,6
#
# Adds new columns containing the specified RDTSC tick values converted
# to microseconds. In this example, the values in the 4th (3), 5th (4), 6th (5)
# and 7th (6) columns are converted using a CPU frequency of 2.7 GHz.
import argparse
import os
import csv
from pathlib import Path
from typing import List


def rdtscToMicroseconds(directory_path: str,
                        columns: List[int], frequencyGHz: float):
    # Calculate conversion factor (Ticks per microsecond)
    frequencyHz = frequencyGHz * 1e9
    ticksPerMicrosecond = frequencyHz * 1e-6

    dir_path = Path(directory_path)

    for item in dir_path.iterdir():
        if item.is_file() and item.suffix == ".csv":
            comments = []

            # 1. Read comments first
            with open(item, 'r', newline='', encoding='utf-8') as f:
                for line in f:
                    if line.strip().startswith("#"):
                        comments.append(line)
                    else:
                        break

            # 2. Read CSV rows excluding comments
            with open(item, 'r', newline='', encoding='utf-8') as f:
                csv_filter = (line for line in f if not
                              line.strip().startswith("#") and line.strip())
                reader = list(csv.reader(csv_filter))

            if not reader:
                continue  # Skip empty files or files containing only comments

            headers = reader[0]

            # 3. Append modified headers
            for col in columns:
                if col < len(headers):
                    modified_header = headers[col].replace("(ticks)", "(μs)")
                    headers.append(modified_header)

            # 4. Compute and append microsecond values to data rows
            for row in reader[1:]:
                for col in columns:
                    if col < len(row):
                        try:
                            microseconds = float(row[col]) \
                                / ticksPerMicrosecond
                            row.append(str(microseconds))
                        except ValueError:
                            # Gracefully handle non-numeric data safely
                            row.append("")

            # 5. Overwrite the file with comments and updated CSV rows
            with open(item, 'w', newline='', encoding='utf-8') as out:
                out.writelines(comments)
                writer = csv.writer(out)
                writer.writerows(reader)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--directory", required=True,
                        help="Location to directory with " +
                        "relevant csv files to modify")
    parser.add_argument("-c", "--columns", required=True,
                        help="Comma separated list of columns" +
                        " with data in ticks (e.g., 3,4,5,6)")
    parser.add_argument("-f", "--frequency", required=True, type=float,
                        help="CPU frequency in GHz (e.g., 2.7)")
    args = parser.parse_args()

    # Parse column string integers into a concrete integer list
    try:
        columns = [int(c) for c in args.columns.split(',')]
    except ValueError:
        raise Exception(
            "Columns flag must be a comma-separated list of integers.")

    # Note: This looks relative to the script location.
    # Change to `os.path.abspath(args.directory)`
    # if you want it relative to your current shell path.
    directory_path = os.path.join(os.path.dirname(__file__), args.directory)

    if os.path.isdir(directory_path):
        rdtscToMicroseconds(directory_path, columns, args.frequency)
    else:
        raise Exception(f"Invalid directory path: {directory_path}")


if __name__ == "__main__":
    main()
