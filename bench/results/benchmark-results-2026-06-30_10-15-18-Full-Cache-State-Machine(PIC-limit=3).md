# jvm

## -O1

| Benchmark      | tier0      | tier1      |
|:---------------|-----------:|-----------:
| bounce         |   486.75ms |   565.88ms |
| cd             | 39550.96ms | 37525.03ms |
| deltablue      |  3807.93ms |  5205.26ms |
| empty          |   144.58ms |   169.63ms |
| globalLongName |   921.69ms |   969.28ms |
| globals        |  4311.04ms |  4193.94ms |
| json           |   957.01ms |  1211.91ms |
| list           |   305.95ms |   329.77ms |
| permute        |   463.85ms |   478.93ms |
| queens         |   458.35ms |   478.12ms |
| richards       |  2054.49ms |  2483.08ms |
| sieve          |   516.62ms |   696.77ms |
| storage        |   558.27ms |   605.33ms |
| towers         |   504.76ms |   517.68ms |


## -O2

| Benchmark      | tier0      | tier1      |
|:---------------|-----------:|-----------:
| bounce         |   475.53ms |   562.99ms |
| cd             | 40002.34ms | 35722.22ms |
| deltablue      |  3782.83ms |  5012.06ms |
| empty          |   139.50ms |   161.63ms |
| globalLongName |   913.63ms |   942.92ms |
| globals        |  4302.36ms |  4143.91ms |
| json           |   946.43ms |  1203.86ms |
| list           |   303.94ms |   321.96ms |
| permute        |   450.85ms |   473.71ms |
| queens         |   446.36ms |   468.65ms |
| richards       |  2034.23ms |  2471.94ms |
| sieve          |   511.46ms |   671.13ms |
| storage        |   562.65ms |   593.39ms |
| towers         |   499.91ms |   501.97ms |


# x86-64-linux

## -O1

| Benchmark      | tier0      | tier1       |
|:---------------|-----------:|------------:
| bounce         |   248.68ms |    279.19ms |
| cd             | 94608.00ms | 110439.92ms |
| deltablue      |  6985.19ms |   8084.23ms |
| empty          |     0.74ms |      4.91ms |
| globalLongName |  1603.93ms |   1089.54ms |
| globals        |  7527.53ms |   8442.14ms |
| json           |  1079.02ms |   1266.73ms |
| list           |    85.08ms |    119.97ms |
| permute        |   239.07ms |    269.77ms |
| queens         |   219.85ms |    240.54ms |
| richards       |  2734.39ms |   2570.17ms |
| sieve          |   374.92ms |    460.81ms |
| storage        |   519.44ms |    575.37ms |
| towers         |   303.37ms |    328.93ms |


## -O2

| Benchmark      | tier0      | tier1      |
|:---------------|-----------:|-----------:
| bounce         |   194.92ms |   232.85ms |
| cd             | 53021.29ms | 74133.62ms |
| deltablue      |  4276.48ms |  5465.89ms |
| empty          |     0.27ms |     4.22ms |
| globalLongName |   892.92ms |   695.97ms |
| globals        |  4132.14ms |  5247.06ms |
| json           |   690.91ms |   912.74ms |
| list           |    71.27ms |   115.41ms |
| permute        |   185.11ms |   231.13ms |
| queens         |   172.50ms |   205.29ms |
| richards       |  1535.32ms |  1912.77ms |
| sieve          |   294.47ms |   353.47ms |
| storage        |   368.00ms |   436.25ms |
| towers         |   235.03ms |   283.76ms |


---

# Configuration

* `BENCH_TARGETS`: jvm, x86-64-linux

* `BENCH_TIERS`: 0, 1

* `BENCH_OPT_LEVELS`: 1, 2


## Benchmark Runs (`/home/supreme/cicero-forked/bench/run_bench.config.csv`)

| Benchmark | Files | Runs |
|:----------|:------|-----:|
| bounce | `micro/bounce.co` | 50 |
| cd | `som/constants.co som/vector.co macro/cd.co` | 20 |
| deltablue | `som/constants.co som/vector.co som/dictionary.co som/identity_dictionary.co macro/deltablue.co` | 50 |
| globalLongName | `micro/globalLongName.co` | 50 |
| globals | `micro/globals.co` | 50 |
| json | `som/constants.co som/vector.co macro/json.co` | 50 |
| list | `micro/list.co` | 50 |
| permute | `micro/permute.co` | 50 |
| queens | `micro/queens.co` | 50 |
| richards | `macro/richards.co` | 50 |
| sieve | `micro/sieve.co` | 50 |
| storage | `micro/storage.co` | 50 |
| towers | `micro/towers.co` | 50 |