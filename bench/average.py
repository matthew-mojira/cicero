from __future__ import annotations
from typing import List, Dict
# python average.py -d results/callerCalleePairs --keys 0,2 --columns 5
# python average.py -d results/funcCalls --keys 0 --columns 3,4
import argparse
import os
import re
import pandas as pd

from pathlib import Path


def group_files(directory: Path) -> Dict[str, List[Path]]:
    file_groups = {}
    # Match any characters followed by digits right before '.csv'
    # e.g., "bounce12.csv" -> base: "bounce", num: "12"
    file_pattern = re.compile(r"^([A-Za-z]*)(\d+)\.csv$")
    # 1. Group files by their base name prefix
    for item in directory.iterdir():
        if item.is_file():
            match = file_pattern.match(item.name)
            if match:
                base_name, _ = match.groups()
                if base_name not in file_groups:
                    file_groups[base_name] = []
                file_groups[base_name].append(item)
    return file_groups


def run(directory: str, keys: List[str], columns: List[str]):

    dir_path = Path(directory)
    file_groups: Dict[str, List[Path]] = group_files(dir_path)
    if not file_groups:
        print("No numbered CSV files found in the target directory.")
        return

    # 2. Process each group
    for base_name, files in file_groups.items():
        print(f"Processing group '{base_name}' ({len(files)} files)...")
        dfs = []
        comments = []
        commentsRead = False
        for file in files:
            if not commentsRead:
                with open(file, 'r') as f:
                    lines = f.readlines()
                for line in lines:
                    if line.strip().startswith("#"):
                        comments.append(line)
                commentsRead = True

            df = pd.read_csv(
                file, comment='#', skipinitialspace=True, encoding='utf-8')
            dfs.append(df)

        if not dfs:
            continue

        combined_df = pd.concat(dfs, ignore_index=True)
        ref_cols = dfs[0].columns
        key_cols = [ref_cols[int(k)] for k in keys]
        target_cols = [ref_cols[int(c)] for c in columns]

        for col in target_cols:
            combined_df[col] = pd.to_numeric(combined_df[col], errors='coerce')

        agg_map = {}
        for col in ref_cols:
            if col in key_cols:
                continue
            elif col in target_cols:
                agg_map[col] = ['mean', 'std']
            else:
                agg_map[col] = 'first'

        aggregated = combined_df.groupby(key_cols).agg(agg_map)

        flattened_cols = []
        for col, agg_type in aggregated.columns:
            if agg_type == 'mean':
                flattened_cols.append(col)
            elif agg_type == 'std':
                flattened_cols.append(f"{col}_std")
            else:
                flattened_cols.append(col)
        aggregated.columns = flattened_cols

        # Pull key columns back into normal columns
        final_df = aggregated.reset_index()
        final_df = final_df.fillna(0)

        # Reorder columns to ensure the new _std columns
        # sit cleanly next to their originals
        # instead of being thrown randomly at the end of the file
        ordered_cols = []
        for col in ref_cols:
            ordered_cols.append(col)
            if col in target_cols:
                ordered_cols.append(f"{col}_std")
        final_df = final_df[ordered_cols]

        # 5. Save the aggregated output
        output_file = dir_path / f"{base_name}.csv"
        with open(output_file, 'w') as f:
            for c in comments:
                f.write(c)
            final_df.to_csv(f, index=False)
            print(f"Generated aggregated summary: {output_file.name}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--directory",
                        required=True,
                        help="Relative location to directory"
                        + " with all the csv files")
    parser.add_argument("-c", "--columns",
                        required=True,
                        help="Column to take the avergae of" +
                              ", across similarly named csv files",
                        type=str)
    parser.add_argument("-k", "--keys",
                        required=True,
                        help="Column Keys to identify the same row",
                        type=str)
    args = parser.parse_args()

    columns = args.columns.split(',')
    keys = args.keys.split(',')

    directory_path = os.path.join(os.path.dirname(__file__), args.directory)
    if os.path.isdir(directory_path):
        run(directory_path, keys, columns)
    else:
        raise Exception("Invalid directory")


if __name__ == "__main__":
    main()
