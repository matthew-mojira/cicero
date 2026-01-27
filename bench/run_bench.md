## README for bench/run_bench.sh
The `run_bench.sh` script automates building cicero across multiple Virgil compiler optimization levels (e.g. `-O0`, `-O1`, `-O2`), and it runs benchmarks (using `hyperfine`) across all provided targets and tiers. Results are stored as timestamped markdown files in the `results/` subdirectory inside `bench/`

### Requirements
* Virgil compiler
* `make`
* `hyperfine`
* `python3`

### Usage
```bash
bash path/to/cicero-repo/scripts/run_bench.sh
```
The benchmarks take a while. So, recommended to use `nohup` like this:
```bash
nohup bash path/to/run_bench.sh &
```

### Configuration
You can config/add/edit benchmarks, number of runs by editing the `/path/to/cicero-repo/bench/run_bench.config.csv` file.

### Optional env vars
By default, the benchmarks only run for the `x86-64-linux` target across tiers `0` and `1` with Virgil optimization level `2`, but you can change it with the following environment variables:
* `BENCH_TARGETS`: which targets to test (e.g `export BENCH_TARGETS="x86-linux x86-64-linux"`)
* `BENCH_TIERS`: which tiers to test (e.g `export BENCH_TIERS="0 1"`)
* `BENCH_OPT_LEVELS`: which Virgil optimization levels to test (e.g `export BENCH_OPT_LEVELS="0 1 2"`)
* `BENCH_CONFIG`: path to benchmark configuration CSV file, default is `bench/run_bench.config.csv` (e.g `export BENCH_CONFIG="/path/to/custom_benchmarks.csv"`)
* `WARMUP_RUNS`: number of warmup runs for hyperfine, default is 1 (e.g `export WARMUP_RUNS=3`)
* `MAX_TASKS`: max number of hyperfine processes to run in parallel, default is 10 (e.g `export MAX_TASKS=30`)

