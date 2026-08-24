# jvm

## -O1

| Benchmark      | tier0      | tier1      |
|:---------------|-----------:|-----------:
| bounce         |   469.74ms |   555.62ms |
| cd             | 39951.54ms | 36645.79ms |
| deltablue      |  3855.30ms |  4250.73ms |
| empty          |   144.94ms |   173.22ms |
| globalLongName |   906.68ms |   977.17ms |
| globals        |  4290.36ms |  4211.90ms |
| json           |   954.22ms |  1148.13ms |
| list           |   302.94ms |   326.86ms |
| permute        |   462.48ms |   486.30ms |
| queens         |   451.01ms |   474.82ms |
| richards       |  2032.58ms |  2215.62ms |
| sieve          |   517.94ms |   687.22ms |
| storage        |   548.13ms |   607.90ms |
| towers         |   500.70ms |   516.10ms |


## -O2

| Benchmark      | tier0      | tier1      |
|:---------------|-----------:|-----------:
| bounce         |   468.89ms |   552.04ms |
| cd             | 39453.74ms | 35472.00ms |
| deltablue      |  3772.76ms |  4147.96ms |
| empty          |   136.34ms |   164.25ms |
| globalLongName |   902.58ms |   982.37ms |
| globals        |  4230.94ms |  4184.38ms |
| json           |   942.39ms |  1163.18ms |
| list           |   300.44ms |   326.63ms |
| permute        |   451.54ms |   478.97ms |
| queens         |   443.58ms |   463.29ms |
| richards       |  2035.05ms |  2191.38ms |
| sieve          |   519.49ms |   689.55ms |
| storage        |   553.96ms |   592.52ms |
| towers         |   480.29ms |   504.00ms |


# x86-64-linux

## -O1

| Benchmark      | tier0      | tier1       |
|:---------------|-----------:|------------:
| bounce         |   247.12ms |    278.75ms |
| cd             | 92683.39ms | 108306.16ms |
| deltablue      |  6961.02ms |   8060.31ms |
| empty          |     0.89ms |      4.88ms |
| globalLongName |  1607.79ms |   1084.40ms |
| globals        |  7385.15ms |   8422.99ms |
| json           |  1078.77ms |   1264.45ms |
| list           |    85.75ms |    119.82ms |
| permute        |   236.85ms |    267.14ms |
| queens         |   219.61ms |    241.70ms |
| richards       |  2713.21ms |   2557.17ms |
| sieve          |   373.37ms |    461.70ms |
| storage        |   512.86ms |    573.06ms |
| towers         |   302.47ms |    324.42ms |


## -O2

| Benchmark      | tier0      | tier1      |
|:---------------|-----------:|-----------:
| bounce         |   197.07ms |   239.14ms |
| cd             | 52610.74ms | 74271.48ms |
| deltablue      |  4270.09ms |  5410.31ms |
| empty          |     0.84ms |     4.21ms |
| globalLongName |   901.10ms |   711.35ms |
| globals        |  4155.00ms |  5244.58ms |
| json           |   691.68ms |   915.62ms |
| list           |    71.11ms |   115.22ms |
| permute        |   187.45ms |   230.38ms |
| queens         |   174.82ms |   203.78ms |
| richards       |  1531.50ms |  1928.56ms |
| sieve          |   295.29ms |   357.49ms |
| storage        |   372.02ms |   442.52ms |
| towers         |   233.74ms |   285.32ms |


---

# Configuration

* `BENCH_TARGETS`: jvm, x86-64-linux

* `BENCH_TIERS`: 0, 1

* `BENCH_OPT_LEVELS`: 1, 2


## Benchmark Runs (`/home/supreme/cicero-forked/bench/run_bench.config.csv`)

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