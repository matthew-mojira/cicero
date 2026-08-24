# jvm

## -O1

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  12163.53ms |
| bounce           |    457.31ms |
| cd               |  33365.64ms |
| deltablue        |   3382.00ms |
| empty            |    170.34ms |
| global_long_name |    794.31ms |
| globals          |   3768.80ms |
| json             |    925.88ms |
| list             |    285.07ms |
| mandelbrot       | 132884.01ms |
| monomorphic      |   4141.37ms |
| nbody            | 139431.09ms |
| permute          |    448.12ms |
| polymorphic      |  12137.32ms |
| queens           |    422.60ms |
| richards         |   1251.84ms |
| sieve            |    508.95ms |
| storage          |    576.14ms |
| towers           |    482.69ms |


## -O2

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  11948.80ms |
| bounce           |    461.23ms |
| cd               |  32947.32ms |
| deltablue        |   3508.18ms |
| empty            |    166.28ms |
| global_long_name |    806.24ms |
| globals          |   3773.45ms |
| json             |    898.93ms |
| list             |    283.99ms |
| mandelbrot       | 134074.10ms |
| monomorphic      |   4234.86ms |
| nbody            | 128967.97ms |
| permute          |    448.51ms |
| polymorphic      |  11884.35ms |
| queens           |    423.42ms |
| richards         |   1290.26ms |
| sieve            |    512.75ms |
| storage          |    598.19ms |
| towers           |    479.61ms |


# x86-64-linux

## -O1

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  25092.00ms |
| bounce           |    223.72ms |
| cd               |  73658.70ms |
| deltablue        |   6699.27ms |
| empty            |      4.93ms |
| global_long_name |    987.62ms |
| globals          |   6569.01ms |
| json             |    885.48ms |
| list             |     50.65ms |
| mandelbrot       | 330831.99ms |
| monomorphic      |   7245.62ms |
| nbody            | 346124.93ms |
| permute          |    205.23ms |
| polymorphic      |  26304.28ms |
| queens           |    192.07ms |
| richards         |   1447.56ms |
| sieve            |    355.15ms |
| storage          |    505.23ms |
| towers           |    234.29ms |


## -O2

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  14511.04ms |
| bounce           |    178.67ms |
| cd               |  44345.93ms |
| deltablue        |   4224.76ms |
| empty            |      4.20ms |
| global_long_name |    637.65ms |
| globals          |   3840.35ms |
| json             |    605.63ms |
| list             |     45.57ms |
| mandelbrot       | 189146.08ms |
| monomorphic      |   4278.31ms |
| nbody            | 200474.53ms |
| permute          |    167.21ms |
| polymorphic      |  15376.47ms |
| queens           |    154.33ms |
| richards         |   1010.25ms |
| sieve            |    279.88ms |
| storage          |    366.69ms |
| towers           |    190.61ms |


# x86-linux

## -O1

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  18495.63ms |
| bounce           |    182.60ms |
| cd               |  60896.21ms |
| deltablue        |   3826.85ms |
| empty            |      3.67ms |
| global_long_name |    739.26ms |
| globals          |   4886.46ms |
| json             |    779.44ms |
| list             |     66.31ms |
| mandelbrot       | 236048.40ms |
| monomorphic      |   6219.44ms |
| nbody            | 250670.35ms |
| permute          |    181.40ms |
| polymorphic      |  19375.10ms |
| queens           |    161.05ms |
| richards         |   1610.76ms |
| sieve            |    281.95ms |
| storage          |    385.65ms |
| towers           |    212.77ms |


## -O2

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  18126.61ms |
| bounce           |    180.31ms |
| cd               |  60898.50ms |
| deltablue        |   3745.28ms |
| empty            |      3.72ms |
| global_long_name |    753.85ms |
| globals          |   4779.08ms |
| json             |    747.66ms |
| list             |     66.26ms |
| mandelbrot       | 233776.37ms |
| monomorphic      |   6140.08ms |
| nbody            | 248162.11ms |
| permute          |    180.10ms |
| polymorphic      |  19026.52ms |
| queens           |    159.33ms |
| richards         |   1561.41ms |
| sieve            |    277.21ms |
| storage          |    379.01ms |
| towers           |    207.35ms |


---

# Configuration

* `BENCH_TARGETS`: jvm, x86-64-linux, x86-linux

* `BENCH_TIERS`: 1

* `BENCH_OPT_LEVELS`: 1, 2


## Benchmark Runs (`/home/supreme/cicero-forked/bench/run_bench.config.csv`)

| Benchmark | Files | Runs |
|:----------|:------|-----:|
| all_cache_phases | `micro/all_cache_phases.co` | 50 |
| bounce | `micro/bounce.co` | 50 |
| cd | `som/constants.co som/vector.co macro/cd.co` | 20 |
| deltablue | `som/constants.co som/vector.co som/dictionary.co som/identity_dictionary.co macro/deltablue.co` | 50 |
| global_long_name | `micro/global_long_name.co` | 50 |
| globals | `micro/globals.co` | 50 |
| json | `som/constants.co som/vector.co macro/json.co` | 50 |
| list | `micro/list.co` | 50 |
| mandelbrot | `micro/mandelbrot.co` | 20 |
| monomorphic | `micro/monomorphic.co` | 50 |
| nbody | `micro/nbody.co` | 20 |
| permute | `micro/permute.co` | 50 |
| polymorphic | `micro/polymorphic.co` | 50 |
| queens | `micro/queens.co` | 50 |
| richards | `macro/richards.co` | 50 |
| sieve | `micro/sieve.co` | 50 |
| storage | `micro/storage.co` | 50 |
| towers | `micro/towers.co` | 50 |