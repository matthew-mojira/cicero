# jvm

## -O1

| Benchmark      | tier0      | tier1      |
|:---------------|-----------:|-----------:
| bounce         |   485.26ms |   555.94ms |
| cd             | 40284.06ms | 38764.99ms |
| deltablue      |  3770.63ms |  4228.67ms |
| empty          |   147.10ms |   179.10ms |
| globalLongName |   907.95ms |   980.75ms |
| globals        |  4278.55ms |  4121.14ms |
| json           |   960.54ms |  1186.57ms |
| list           |   309.87ms |   333.91ms |
| permute        |   465.03ms |   479.31ms |
| queens         |   451.67ms |   476.71ms |
| richards       |  2068.22ms |  2370.13ms |
| sieve          |   524.29ms |   686.36ms |
| storage        |   550.11ms |   590.37ms |
| towers         |   502.28ms |   521.26ms |


## -O2

| Benchmark      | tier0      | tier1      |
|:---------------|-----------:|-----------:
| bounce         |   458.85ms |   547.24ms |
| cd             | 39724.33ms | 37826.20ms |
| deltablue      |  3757.60ms |  4230.68ms |
| empty          |   139.95ms |   164.89ms |
| globalLongName |   917.24ms |   956.01ms |
| globals        |  4274.41ms |  4101.78ms |
| json           |   952.95ms |  1189.31ms |
| list           |   294.29ms |   326.30ms |
| permute        |   451.50ms |   466.92ms |
| queens         |   442.50ms |   469.18ms |
| richards       |  2012.81ms |  2366.66ms |
| sieve          |   507.43ms |   651.55ms |
| storage        |   544.46ms |   584.58ms |
| towers         |   495.31ms |   512.17ms |


# x86-64-linux

## -O1

| Benchmark      | tier0      | tier1       |
|:---------------|-----------:|------------:
| bounce         |   248.66ms |    284.65ms |
| cd             | 94401.88ms | 113835.72ms |
| deltablue      |  6979.80ms |   8371.09ms |
| empty          |     0.92ms |      4.84ms |
| globalLongName |  1589.47ms |   1078.25ms |
| globals        |  7408.77ms |   8121.92ms |
| json           |  1081.31ms |   1353.00ms |
| list           |    84.71ms |    129.39ms |
| permute        |   236.15ms |    278.33ms |
| queens         |   217.45ms |    248.86ms |
| richards       |  2714.00ms |   3246.14ms |
| sieve          |   374.38ms |    460.61ms |
| storage        |   520.57ms |    576.08ms |
| towers         |   302.75ms |    347.27ms |


## -O2

| Benchmark      | tier0      | tier1      |
|:---------------|-----------:|-----------:
| bounce         |   196.85ms |   235.51ms |
| cd             | 52317.11ms | 75597.45ms |
| deltablue      |  4280.51ms |  5615.88ms |
| empty          |     1.20ms |     4.07ms |
| globalLongName |   889.48ms |   708.35ms |
| globals        |  4162.73ms |  5197.19ms |
| json           |   687.97ms |   953.43ms |
| list           |    71.32ms |   118.74ms |
| permute        |   189.01ms |   238.61ms |
| queens         |   172.66ms |   210.09ms |
| richards       |  1523.13ms |  2247.80ms |
| sieve          |   298.35ms |   356.11ms |
| storage        |   376.86ms |   443.07ms |
| towers         |   231.87ms |   295.58ms |


---

# Configuration

* `BENCH_TARGETS`: jvm, x86-64-linux

* `BENCH_TIERS`: 0, 1

* `BENCH_OPT_LEVELS`: 1, 2


## Benchmark Runs (`/bench/run_bench.config.csv`)

| Benchmark | Files | Runs |
|:----------|:------|-----:|
| bounce | `micro/bounce.co` | 25 |
| cd | `som/constants.co som/vector.co macro/cd.co` | 10 |
| deltablue | `som/constants.co som/vector.co som/dictionary.co som/identity_dictionary.co macro/deltablue.co` | 25 |
| globalLongName | `micro/globalLongName.co` | 25 |
| globals | `micro/globals.co` | 25 |
| json | `som/constants.co som/vector.co macro/json.co` | 25 |
| list | `micro/list.co` | 25 |
| permute | `micro/permute.co` | 25 |
| queens | `micro/queens.co` | 25 |
| richards | `macro/richards.co` | 25 |
| sieve | `micro/sieve.co` | 25 |
| storage | `micro/storage.co` | 25 |
| towers | `micro/towers.co` | 25 |