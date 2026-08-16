# x86-64-linux

## -O0

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  41141.60ms |
| bounce           |    341.75ms |
| cd               | 126943.31ms |
| deltablue        |  12348.99ms |
| empty            |      6.51ms |
| global_long_name |   1572.35ms |
| globals          |  11014.70ms |
| json             |   1484.75ms |
| list             |     68.26ms |
| mandelbrot       | 551547.94ms |
| monomorphic      |  12786.54ms |
| nbody            | 575212.43ms |
| permute          |    307.07ms |
| polymorphic      |  42831.68ms |
| queens           |    289.44ms |
| richards         |   2472.98ms |
| sieve            |    541.57ms |
| storage          |    847.48ms |
| towers           |    356.97ms |


## -O1

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  22679.27ms |
| bounce           |    203.93ms |
| cd               |  67557.80ms |
| deltablue        |   6335.30ms |
| empty            |      4.67ms |
| global_long_name |    907.97ms |
| globals          |   6025.85ms |
| json             |    846.72ms |
| list             |     36.35ms |
| mandelbrot       | 303409.22ms |
| monomorphic      |   6671.54ms |
| nbody            | 315278.07ms |
| permute          |    181.58ms |
| polymorphic      |  23442.92ms |
| queens           |    172.60ms |
| richards         |   1305.37ms |
| sieve            |    329.10ms |
| storage          |    515.50ms |
| towers           |    209.12ms |


## -O2

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  12877.46ms |
| bounce           |    159.65ms |
| cd               |  40990.55ms |
| deltablue        |   4429.86ms |
| empty            |      4.21ms |
| global_long_name |    597.99ms |
| globals          |   3438.23ms |
| json             |    592.64ms |
| list             |     31.05ms |
| mandelbrot       | 172828.74ms |
| monomorphic      |   3958.15ms |
| nbody            | 180056.30ms |
| permute          |    141.59ms |
| polymorphic      |  13061.18ms |
| queens           |    135.12ms |
| richards         |    903.46ms |
| sieve            |    254.18ms |
| storage          |    378.08ms |
| towers           |    161.72ms |


# x86-linux

## -O0

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  18689.02ms |
| bounce           |    180.09ms |
| cd               |  63994.35ms |
| deltablue        |   4325.07ms |
| empty            |      3.95ms |
| global_long_name |    776.25ms |
| globals          |   4893.09ms |
| json             |    772.02ms |
| list             |     60.27ms |
| mandelbrot       | 241418.61ms |
| monomorphic      |   6409.40ms |
| nbody            | 256793.69ms |
| permute          |    174.91ms |
| polymorphic      |  19518.14ms |
| queens           |    156.75ms |
| richards         |   1667.16ms |
| sieve            |    275.20ms |
| storage          |    393.52ms |
| towers           |    207.94ms |


## -O1

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  17661.05ms |
| bounce           |    171.74ms |
| cd               |  59960.29ms |
| deltablue        |   4057.89ms |
| empty            |      3.68ms |
| global_long_name |    743.90ms |
| globals          |   4671.42ms |
| json             |    728.55ms |
| list             |     56.24ms |
| mandelbrot       | 225131.33ms |
| monomorphic      |   6097.74ms |
| nbody            | 238108.62ms |
| permute          |    165.90ms |
| polymorphic      |  18323.29ms |
| queens           |    149.53ms |
| richards         |   1570.88ms |
| sieve            |    264.15ms |
| storage          |    375.82ms |
| towers           |    195.88ms |


## -O2

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  18049.71ms |
| bounce           |    168.39ms |
| cd               |  61166.40ms |
| deltablue        |   4137.08ms |
| empty            |      3.86ms |
| global_long_name |    740.06ms |
| globals          |   4758.80ms |
| json             |    725.15ms |
| list             |     57.97ms |
| mandelbrot       | 223576.69ms |
| monomorphic      |   6139.63ms |
| nbody            | 245384.36ms |
| permute          |    163.07ms |
| polymorphic      |  18707.37ms |
| queens           |    146.46ms |
| richards         |   1585.89ms |
| sieve            |    258.17ms |
| storage          |    370.60ms |
| towers           |    193.82ms |


---

# Configuration

* `BENCH_TARGETS`: x86-64-linux, x86-linux

* `BENCH_TIERS`: 1

* `BENCH_OPT_LEVELS`: 0, 1, 2


## Benchmark Runs (`/home/supreme/cicero-forked/bench/run_bench.config.csv`)

| Benchmark | Files | Runs |
|:----------|:------|-----:|
| all_cache_phases | `micro/all_cache_phases.co` | 50 |
| bounce | `micro/bounce.co` | 50 |
| cd | `som/constants.co som/vector.co macro/cd.co` | 10 |
| deltablue | `som/constants.co som/vector.co som/dictionary.co som/identity_dictionary.co macro/deltablue.co` | 50 |
| global_long_name | `micro/global_long_name.co` | 50 |
| globals | `micro/globals.co` | 50 |
| json | `som/constants.co som/vector.co macro/json.co` | 50 |
| list | `micro/list.co` | 50 |
| mandelbrot | `micro/mandelbrot.co` | 10 |
| monomorphic | `micro/monomorphic.co` | 50 |
| nbody | `micro/nbody.co` | 10 |
| permute | `micro/permute.co` | 50 |
| polymorphic | `micro/polymorphic.co` | 50 |
| queens | `micro/queens.co` | 50 |
| richards | `macro/richards.co` | 50 |
| sieve | `micro/sieve.co` | 50 |
| storage | `micro/storage.co` | 50 |
| towers | `micro/towers.co` | 50 |