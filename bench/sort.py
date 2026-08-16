# e.g. `python sort.py -d results/jumpOutcomes -k 0`
# will sort all the csv files in the results/jumpOutcomes directory
# based on the first column(line number)
import argparse
import os
import io
import pandas as pd

from pathlib import Path


def sort_csv(directory: str, col: int, ascending: bool):
    dir_path = Path(directory)
    for item in dir_path.iterdir():
        if item.is_file() and item.name.endswith(".csv"):
            with open(item, 'r') as f:
                lines = f.readlines()

            comments = []
            csv_lines = []

            # 1. Separate comments from actual CSV data
            for line in lines:
                if line.strip().startswith("#"):
                    comments.append(line)
                elif line.strip():  # Ignore entirely empty lines
                    csv_lines.append(line)

            csv_data = "".join(csv_lines)
            df = pd.read_csv(io.StringIO(csv_data), skipinitialspace=True)

            # 3. Ensure the requested column index is valid
            if col >= len(df.columns):
                print(
                    f"Skipping {item.name}: Column index {col}"
                    + " is out of bounds.")
                continue

            # 4. Sort the DataFrame
            sort_col_name = df.columns[col]
            df_sorted = df.sort_values(by=sort_col_name, ascending=ascending)

            # 5. Write the comments and sorted data to a new file
            with open(item, 'w') as f:
                for c in comments:
                    f.write(c)
                df_sorted.to_csv(f, index=False)
            print(f"Processed: {item.name}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--directory",
                        required=True,
                        help="Relative location to directory"
                        + " with csv files to sort")
    parser.add_argument("-c", "--column",
                        required=True, help="Column to sort on", type=int)
    parser.add_argument("-r", "--reverse", action="store_true")
    args = parser.parse_args()

    directory_path = os.path.join(os.path.dirname(__file__), args.directory)
    if os.path.isdir(directory_path):
        sort_csv(directory_path, args.column, args.reverse)
    else:
        raise Exception("Invalid directory")


if __name__ == "__main__":
    main()
