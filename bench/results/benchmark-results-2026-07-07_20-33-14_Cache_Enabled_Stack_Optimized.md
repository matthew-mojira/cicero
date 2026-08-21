# jvm

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  12011.10ms |  12401.82ms |
| bounce           |    442.70ms |    446.78ms |
| cd               |  40800.52ms |  35304.99ms |
| deltablue        |   3558.34ms |   3538.12ms |
| empty            |    147.93ms |    172.61ms |
| global_long_name |    855.47ms |    793.58ms |
| globals          |   4148.01ms |   3903.09ms |
| json             |    859.76ms |    871.82ms |
| list             |    287.73ms |    286.55ms |
| mandelbrot       | 146435.72ms | 135586.94ms |
| monomorphic      |   4867.69ms |   4379.75ms |
| nbody            | 154665.18ms | 143651.13ms |
| permute          |    431.50ms |    451.84ms |
| polymorphic      |  12357.17ms |  11630.93ms |
| queens           |    422.38ms |    425.48ms |
| richards         |   1844.67ms |   1297.47ms |
| sieve            |    488.79ms |    512.17ms |
| storage          |    525.01ms |    559.66ms |
| towers           |    462.22ms |    480.66ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  12054.26ms |  12339.24ms |
| bounce           |    430.75ms |    441.95ms |
| cd               |  41775.28ms |  35537.03ms |
| deltablue        |   3555.87ms |   3449.09ms |
| empty            |    138.81ms |    164.54ms |
| global_long_name |    862.11ms |    783.42ms |
| globals          |   4222.53ms |   3851.26ms |
| json             |    877.67ms |    868.26ms |
| list             |    281.06ms |    282.04ms |
| mandelbrot       | 144232.65ms | 135588.28ms |
| monomorphic      |   4807.91ms |   4328.99ms |
| nbody            | 157251.40ms | 136835.41ms |
| permute          |    423.67ms |    446.11ms |
| polymorphic      |  12376.78ms |  11774.80ms |
| queens           |    419.08ms |    415.78ms |
| richards         |   1855.06ms |   1321.96ms |
| sieve            |    485.21ms |    502.96ms |
| storage          |    521.79ms |    549.41ms |
| towers           |    457.85ms |    470.51ms |


# x86-64-linux

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  25041.03ms |  24125.96ms |
| bounce           |    242.22ms |    220.71ms |
| cd               |  97039.49ms |  72634.45ms |
| deltablue        |   6962.86ms |   6642.09ms |
| empty            |      1.11ms |      4.99ms |
| global_long_name |   1583.25ms |    962.28ms |
| globals          |   7500.16ms |   6458.58ms |
| json             |   1047.35ms |    875.93ms |
| list             |     84.17ms |     49.22ms |
| mandelbrot       | 362254.74ms | 330081.25ms |
| monomorphic      |   8420.31ms |   7106.47ms |
| nbody            | 387393.52ms | 347626.83ms |
| permute          |    235.47ms |    200.84ms |
| polymorphic      |  26244.79ms |  25102.29ms |
| queens           |    215.01ms |    186.86ms |
| richards         |   2686.83ms |   1441.65ms |
| sieve            |    365.71ms |    344.97ms |
| storage          |    510.36ms |    496.76ms |
| towers           |    295.81ms |    231.93ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  13985.19ms |  13916.69ms |
| bounce           |    194.38ms |    177.04ms |
| cd               |  56284.05ms |  44806.59ms |
| deltablue        |   4241.48ms |   4223.51ms |
| empty            |      0.96ms |      4.21ms |
| global_long_name |    850.96ms |    631.13ms |
| globals          |   4216.06ms |   3767.17ms |
| json             |    691.03ms |    603.46ms |
| list             |     71.54ms |     45.41ms |
| mandelbrot       | 201688.84ms | 193191.62ms |
| monomorphic      |   5009.77ms |   4417.91ms |
| nbody            | 222313.71ms | 202832.90ms |
| permute          |    186.81ms |    166.29ms |
| polymorphic      |  14898.78ms |  14458.65ms |
| queens           |    170.07ms |    154.61ms |
| richards         |   1554.89ms |   1015.38ms |
| sieve            |    293.39ms |    276.95ms |
| storage          |    371.51ms |    365.00ms |
| towers           |    232.83ms |    188.60ms |


# x86-linux

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  15802.55ms |  18462.62ms |
| bounce           |    165.32ms |    180.62ms |
| cd               |  58011.02ms |  61681.71ms |
| deltablue        |   3517.31ms |   3866.29ms |
| empty            |      1.17ms |      3.78ms |
| global_long_name |    907.46ms |    759.20ms |
| globals          |   4759.22ms |   4898.56ms |
| json             |    658.43ms |    778.85ms |
| list             |     61.15ms |     67.87ms |
| mandelbrot       | 220786.93ms | 242572.04ms |
| monomorphic      |   5592.62ms |   6343.36ms |
| nbody            | 238567.89ms | 258308.89ms |
| permute          |    165.48ms |    181.49ms |
| polymorphic      |  16894.67ms |  19223.33ms |
| queens           |    150.83ms |    160.26ms |
| richards         |   1603.46ms |   1638.02ms |
| sieve            |    257.65ms |    280.87ms |
| storage          |    349.21ms |    380.36ms |
| towers           |    208.18ms |    213.04ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  15557.35ms |  18223.64ms |
| bounce           |    168.55ms |    182.36ms |
| cd               |  58042.05ms |  61115.79ms |
| deltablue        |   3531.73ms |   3782.53ms |
| empty            |      1.11ms |      3.78ms |
| global_long_name |    947.72ms |    759.31ms |
| globals          |   4518.60ms |   4866.16ms |
| json             |    686.73ms |    776.74ms |
| list             |     62.57ms |     67.10ms |
| mandelbrot       | 223248.53ms | 244545.26ms |
| monomorphic      |   5537.43ms |   6246.72ms |
| nbody            | 238280.75ms | 257582.61ms |
| permute          |    166.70ms |    181.24ms |
| polymorphic      |  16633.41ms |  18809.15ms |
| queens           |    153.42ms |    160.28ms |
| richards         |   1573.45ms |   1633.26ms |
| sieve            |    258.56ms |    279.04ms |
| storage          |    353.79ms |    381.32ms |
| towers           |    209.28ms |    212.25ms |


---

# Configuration

* `BENCH_TARGETS`: jvm, x86-64-linux, x86-linux

* `BENCH_TIERS`: 0, 1

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