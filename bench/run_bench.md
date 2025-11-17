## README for scripts/run_bench.sh
The `run_bench.sh` script automates building cicero across multiple virgil compiler optimization levels`(-O0, -O1, -O2)`, and it runs benchmarks (using `hyperfine`) across all provided targets, tiers and stores the results (as a `.md` file) in the `results/` subdirectory inside `bench/`

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

### Optional env vars
By default, the benchmarks only run for the `x86-64-linux` target across tiers `0` and `1`, but you can change it with the following environment variables:
* `TARGETS`: which targets to test (e.g `export TARGETS="x86-linux"`)
* `TIERS`: which tiers to test (e.g `export TIERS="0 1"`)

