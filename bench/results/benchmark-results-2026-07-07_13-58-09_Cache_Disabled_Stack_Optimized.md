# jvm

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  11968.99ms |  12214.75ms |
| bounce           |    438.01ms |    438.66ms |
| cd               |  40967.31ms |  37671.07ms |
| deltablue        |   3535.12ms |   3485.45ms |
| empty            |    144.35ms |    171.34ms |
| global_long_name |    853.81ms |    791.10ms |
| globals          |   4143.88ms |   3810.74ms |
| json             |    860.71ms |    845.59ms |
| list             |    288.25ms |    286.40ms |
| mandelbrot       | 144580.23ms | 133474.19ms |
| monomorphic      |   4850.51ms |   4661.18ms |
| nbody            | 155453.34ms | 143189.34ms |
| permute          |    428.08ms |    439.80ms |
| polymorphic      |  12206.44ms |  12072.94ms |
| queens           |    421.18ms |    420.58ms |
| richards         |   1846.38ms |   1444.80ms |
| sieve            |    484.44ms |    509.58ms |
| storage          |    525.89ms |    550.01ms |
| towers           |    467.01ms |    475.27ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  11852.15ms |  12206.38ms |
| bounce           |    430.76ms |    429.11ms |
| cd               |  40982.32ms |  36270.12ms |
| deltablue        |   3539.42ms |   3400.90ms |
| empty            |    137.77ms |    160.60ms |
| global_long_name |    849.10ms |    777.51ms |
| globals          |   4119.17ms |   3783.75ms |
| json             |    865.65ms |    828.20ms |
| list             |    280.96ms |    277.83ms |
| mandelbrot       | 144603.31ms | 132614.09ms |
| monomorphic      |   4788.62ms |   4632.64ms |
| nbody            | 155231.84ms | 138803.20ms |
| permute          |    426.49ms |    432.13ms |
| polymorphic      |  12126.68ms |  11951.73ms |
| queens           |    414.16ms |    404.81ms |
| richards         |   1847.22ms |   1437.66ms |
| sieve            |    478.22ms |    495.90ms |
| storage          |    520.15ms |    546.64ms |
| towers           |    454.18ms |    472.38ms |


# x86-64-linux

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  24330.74ms |  24574.18ms |
| bounce           |    241.71ms |    225.75ms |
| cd               |  97072.96ms |  76889.68ms |
| deltablue        |   6959.96ms |   7104.13ms |
| empty            |      1.03ms |      4.89ms |
| global_long_name |   1546.24ms |    944.27ms |
| globals          |   7457.98ms |   6476.76ms |
| json             |   1042.29ms |    960.73ms |
| list             |     84.61ms |     58.06ms |
| mandelbrot       | 361119.44ms | 328198.70ms |
| monomorphic      |   8406.91ms |   7500.77ms |
| nbody            | 386132.68ms | 351535.73ms |
| permute          |    230.51ms |    210.38ms |
| polymorphic      |  26240.65ms |  25670.43ms |
| queens           |    212.21ms |    199.16ms |
| richards         |   2639.74ms |   2097.88ms |
| sieve            |    362.23ms |    347.82ms |
| storage          |    508.28ms |    494.14ms |
| towers           |    295.69ms |    249.89ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  14092.10ms |  14123.40ms |
| bounce           |    193.20ms |    182.87ms |
| cd               |  56421.00ms |  46034.46ms |
| deltablue        |   4234.69ms |   4467.74ms |
| empty            |      0.99ms |      4.27ms |
| global_long_name |    853.37ms |    627.65ms |
| globals          |   4215.33ms |   3748.78ms |
| json             |    682.25ms |    649.51ms |
| list             |     71.56ms |     49.94ms |
| mandelbrot       | 198337.36ms | 184830.83ms |
| monomorphic      |   5016.55ms |   4698.06ms |
| nbody            | 214308.75ms | 200317.76ms |
| permute          |    185.12ms |    173.09ms |
| polymorphic      |  14995.42ms |  14819.34ms |
| queens           |    170.07ms |    161.41ms |
| richards         |   1554.78ms |   1316.46ms |
| sieve            |    290.81ms |    281.06ms |
| storage          |    371.95ms |    368.53ms |
| towers           |    231.82ms |    201.80ms |


# x86-linux

## -O1

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  15786.92ms |  18308.61ms |
| bounce           |    165.01ms |    178.58ms |
| cd               |  57827.15ms |  63396.34ms |
| deltablue        |   3518.86ms |   3980.22ms |
| empty            |      1.12ms |      3.74ms |
| global_long_name |    878.29ms |    737.26ms |
| globals          |   4733.46ms |   4853.90ms |
| json             |    681.78ms |    804.60ms |
| list             |     62.49ms |     68.82ms |
| mandelbrot       | 220822.06ms | 239837.39ms |
| monomorphic      |   5556.05ms |   6448.64ms |
| nbody            | 239051.85ms | 260536.17ms |
| permute          |    164.91ms |    179.93ms |
| polymorphic      |  16888.43ms |  18512.17ms |
| queens           |    151.54ms |    159.14ms |
| richards         |   1598.22ms |   1820.64ms |
| sieve            |    251.89ms |    271.66ms |
| storage          |    349.85ms |    371.49ms |
| towers           |    206.47ms |    216.86ms |


## -O2

| Benchmark        | tier0       | tier1       |
|:-----------------|------------:|------------:
| all_cache_phases |  15637.51ms |  18146.76ms |
| bounce           |    166.47ms |    183.64ms |
| cd               |  58011.05ms |  63406.59ms |
| deltablue        |   3499.85ms |   3927.78ms |
| empty            |      1.10ms |      3.74ms |
| global_long_name |    948.21ms |    753.03ms |
| globals          |   4662.69ms |   4820.67ms |
| json             |    687.92ms |    808.50ms |
| list             |     62.00ms |     70.32ms |
| mandelbrot       | 218315.63ms | 236379.47ms |
| monomorphic      |   5578.24ms |   6428.75ms |
| nbody            | 236182.23ms | 256670.18ms |
| permute          |    166.11ms |    184.72ms |
| polymorphic      |  16730.12ms |  18802.45ms |
| queens           |    152.56ms |    165.84ms |
| richards         |   1619.29ms |   1890.50ms |
| sieve            |    251.24ms |    278.77ms |
| storage          |    354.07ms |    382.22ms |
| towers           |    208.77ms |    222.11ms |


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