# jvm

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  12336.06ms |  13539.88ms |
| bounce           |    478.87ms |    587.62ms |
| cd               |  41982.30ms |  38619.25ms |
| deltablue        |   3835.10ms |   5446.33ms |
| empty            |    162.79ms |    179.35ms |
| global_long_name |    921.05ms |   1014.47ms |
| globals          |   4303.36ms |   4384.60ms |
| json             |    907.83ms |   1207.34ms |
| list             |    320.73ms |    338.63ms |
| mandelbrot       | 147466.13ms | 146269.13ms |
| monomorphic      |   5086.97ms |   4932.48ms |
| nbody            | 158292.34ms | 149544.54ms |
| permute          |    469.47ms |    508.74ms |
| polymorphic      |  12955.23ms |  12237.52ms |
| queens           |    464.19ms |    509.88ms |
| richards         |   2002.31ms |   2467.01ms |
| sieve            |    534.90ms |    725.39ms |
| storage          |    572.06ms |    632.65ms |
| towers           |    507.81ms |    542.34ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  12628.57ms |  13673.07ms |
| bounce           |    489.56ms |    590.63ms |
| cd               |  42751.57ms |  39032.96ms |
| deltablue        |   3941.83ms |   5709.67ms |
| empty            |    154.59ms |    173.60ms |
| global_long_name |    934.20ms |   1011.35ms |
| globals          |   4438.97ms |   4360.74ms |
| json             |    923.44ms |   1233.29ms |
| list             |    328.55ms |    332.27ms |
| mandelbrot       | 146342.54ms | 144789.16ms |
| monomorphic      |   5235.45ms |   4963.58ms |
| nbody            | 156881.01ms | 148035.94ms |
| permute          |    498.76ms |    496.93ms |
| polymorphic      |  12833.09ms |  12448.27ms |
| queens           |    483.80ms |    496.15ms |
| richards         |   2117.31ms |   2597.92ms |
| sieve            |    537.70ms |    727.55ms |
| storage          |    572.58ms |    624.86ms |
| towers           |    517.39ms |    522.80ms |


# x86-64-linux

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  26029.59ms |  27458.97ms |
| bounce           |    248.09ms |    280.90ms |
| cd               | 101291.23ms | 118803.23ms |
| deltablue        |   7171.10ms |   8285.61ms |
| empty            |      0.64ms |      4.38ms |
| global_long_name |   1607.32ms |   1091.63ms |
| globals          |   7608.97ms |   8618.02ms |
| json             |   1074.54ms |   1276.97ms |
| list             |     85.78ms |    119.11ms |
| mandelbrot       | 365467.64ms | 420153.94ms |
| monomorphic      |   8647.62ms |   9214.47ms |
| nbody            | 390284.15ms | 435089.85ms |
| permute          |    236.53ms |    271.41ms |
| polymorphic      |  27354.55ms |  28591.26ms |
| queens           |    220.55ms |    241.08ms |
| richards         |   2715.65ms |   2575.59ms |
| sieve            |    374.50ms |    464.30ms |
| storage          |    522.49ms |    578.57ms |
| towers           |    305.20ms |    330.28ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  15062.87ms |  17248.18ms |
| bounce           |    200.43ms |    238.57ms |
| cd               |  59700.69ms |  81868.02ms |
| deltablue        |   4478.14ms |   5883.09ms |
| empty            |      0.67ms |      4.02ms |
| global_long_name |    903.30ms |    715.72ms |
| globals          |   4251.70ms |   5762.57ms |
| json             |    700.11ms |    929.40ms |
| list             |     72.70ms |    117.21ms |
| mandelbrot       | 201191.50ms | 258940.93ms |
| monomorphic      |   5252.43ms |   6224.42ms |
| nbody            | 215604.67ms | 266174.57ms |
| permute          |    194.32ms |    233.04ms |
| polymorphic      |  16095.64ms |  17860.45ms |
| queens           |    178.33ms |    211.77ms |
| richards         |   1575.42ms |   1952.97ms |
| sieve            |    301.22ms |    363.99ms |
| storage          |    375.98ms |    446.88ms |
| towers           |    241.28ms |    289.30ms |


# x86-linux

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  15999.15ms |  21566.39ms |
| bounce           |    168.51ms |    247.01ms |
| cd               |  59639.87ms | 111047.69ms |
| deltablue        |   3524.85ms |   5821.78ms |
| empty            |      1.20ms |      3.53ms |
| global_long_name |    921.34ms |    877.90ms |
| globals          |   4668.55ms |   7039.07ms |
| json             |    690.63ms |   1189.54ms |
| list             |     61.48ms |    147.91ms |
| mandelbrot       | 219003.14ms | 337919.34ms |
| monomorphic      |   5471.84ms |   8413.60ms |
| nbody            | 236422.79ms | 351675.18ms |
| permute          |    169.57ms |    258.17ms |
| polymorphic      |  17142.40ms |  22629.95ms |
| queens           |    152.83ms |    218.04ms |
| richards         |   1608.68ms |   2899.04ms |
| sieve            |    260.71ms |    367.08ms |
| storage          |    357.69ms |    515.41ms |
| towers           |    208.57ms |    321.30ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  16690.83ms |  22280.04ms |
| bounce           |    167.51ms |    246.00ms |
| cd               |  61674.49ms | 112558.49ms |
| deltablue        |   3567.16ms |   6006.28ms |
| empty            |      1.07ms |      3.73ms |
| global_long_name |    958.08ms |    886.62ms |
| globals          |   4699.65ms |   7235.96ms |
| json             |    698.19ms |   1190.86ms |
| list             |     61.83ms |    146.36ms |
| mandelbrot       | 218116.49ms | 331967.23ms |
| monomorphic      |   5634.77ms |   8646.42ms |
| nbody            | 237326.80ms | 343598.09ms |
| permute          |    167.64ms |    255.70ms |
| polymorphic      |  17636.67ms |  23075.97ms |
| queens           |    153.62ms |    222.60ms |
| richards         |   1622.68ms |   2914.30ms |
| sieve            |    258.56ms |    363.79ms |
| storage          |    354.88ms |    516.88ms |
| towers           |    207.90ms |    322.15ms |


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