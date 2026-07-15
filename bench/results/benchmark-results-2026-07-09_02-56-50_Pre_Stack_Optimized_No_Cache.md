# x86-64-linux

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  25413.25ms |  27370.75ms |
| bounce           |    248.93ms |    288.27ms |
| cd               |  99751.00ms | 122271.09ms |
| deltablue        |   7131.01ms |   8632.59ms |
| empty            |      0.64ms |      4.79ms |
| global_long_name |   1605.65ms |   1090.41ms |
| globals          |   7554.82ms |   8441.54ms |
| json             |   1072.47ms |   1368.73ms |
| list             |     85.56ms |    128.83ms |
| mandelbrot       | 362488.87ms | 414437.09ms |
| monomorphic      |   8548.35ms |   9624.12ms |
| nbody            | 387142.79ms | 436470.83ms |
| permute          |    237.63ms |    279.98ms |
| polymorphic      |  26749.14ms |  28570.17ms |
| queens           |    219.60ms |    255.41ms |
| richards         |   2707.59ms |   3259.54ms |
| sieve            |    375.00ms |    464.96ms |
| storage          |    523.99ms |    584.09ms |
| towers           |    303.61ms |    352.84ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  13795.53ms |  15975.25ms |
| bounce           |    195.88ms |    239.36ms |
| cd               |  55735.92ms |  81430.74ms |
| deltablue        |   4363.41ms |   5806.80ms |
| empty            |      0.54ms |      3.49ms |
| global_long_name |    892.89ms |    709.87ms |
| globals          |   4169.36ms |   5243.03ms |
| json             |    686.19ms |    961.68ms |
| list             |     71.16ms |    119.84ms |
| mandelbrot       | 193502.37ms | 252030.69ms |
| monomorphic      |   4929.96ms |   6140.95ms |
| nbody            | 208712.43ms | 264284.58ms |
| permute          |    189.13ms |    240.86ms |
| polymorphic      |  14732.73ms |  16753.62ms |
| queens           |    171.77ms |    211.37ms |
| richards         |   1521.99ms |   2239.95ms |
| sieve            |    295.28ms |    357.64ms |
| storage          |    375.80ms |    445.82ms |
| towers           |    235.08ms |    296.27ms |


# x86-linux

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  15621.03ms |  20856.12ms |
| bounce           |    167.39ms |    249.48ms |
| cd               |  58043.13ms | 110872.97ms |
| deltablue        |   3512.85ms |   5951.47ms |
| empty            |      1.08ms |      3.00ms |
| global_long_name |    921.32ms |    871.45ms |
| globals          |   4656.46ms |   6971.72ms |
| json             |    691.72ms |   1214.40ms |
| list             |     58.84ms |    150.33ms |
| mandelbrot       | 216718.56ms | 331762.98ms |
| monomorphic      |   5455.47ms |   8447.12ms |
| nbody            | 233245.42ms | 348329.92ms |
| permute          |    167.34ms |    258.37ms |
| polymorphic      |  16685.53ms |  21773.26ms |
| queens           |    153.71ms |    222.47ms |
| richards         |   1608.20ms |   3163.73ms |
| sieve            |    258.79ms |    362.77ms |
| storage          |    356.85ms |    512.03ms |
| towers           |    209.25ms |    332.78ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  15346.74ms |  20626.08ms |
| bounce           |    166.12ms |    248.22ms |
| cd               |  57469.32ms | 110273.79ms |
| deltablue        |   3521.90ms |   5977.12ms |
| empty            |      1.12ms |      3.52ms |
| global_long_name |    941.82ms |    860.18ms |
| globals          |   4555.34ms |   6865.30ms |
| json             |    684.87ms |   1211.87ms |
| list             |     59.96ms |    150.32ms |
| mandelbrot       | 212332.33ms | 320329.24ms |
| monomorphic      |   5386.19ms |   8349.89ms |
| nbody            | 228877.23ms | 339350.15ms |
| permute          |    165.10ms |    257.55ms |
| polymorphic      |  16387.51ms |  21453.15ms |
| queens           |    149.75ms |    221.36ms |
| richards         |   1583.86ms |   3152.81ms |
| sieve            |    258.13ms |    359.84ms |
| storage          |    351.94ms |    509.19ms |
| towers           |    205.33ms |    332.03ms |


---

# Configuration

* `BENCH_TARGETS`: x86-64-linux, x86-linux

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