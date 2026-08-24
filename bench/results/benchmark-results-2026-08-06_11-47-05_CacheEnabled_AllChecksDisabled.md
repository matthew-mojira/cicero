# x86-64-linux

## -O0

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  39873.12ms |
| bounce           |    328.01ms |
| cd               | 121183.87ms |
| deltablue        |  12023.33ms |
| empty            |      5.72ms |
| global_long_name |   1503.43ms |
| globals          |  10505.93ms |
| json             |   1427.64ms |
| list             |     66.14ms |
| mandelbrot       | 518398.48ms |
| monomorphic      |  12128.03ms |
| nbody            | 547612.17ms |
| permute          |    296.34ms |
| polymorphic      |  41558.71ms |
| queens           |    280.23ms |
| richards         |   2376.90ms |
| sieve            |    523.13ms |
| storage          |    816.17ms |
| towers           |    345.35ms |


## -O1

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  21839.84ms |
| bounce           |    200.13ms |
| cd               |  66038.33ms |
| deltablue        |   6202.00ms |
| empty            |      4.95ms |
| global_long_name |    882.38ms |
| globals          |   5872.20ms |
| json             |    829.77ms |
| list             |     35.52ms |
| mandelbrot       | 294587.24ms |
| monomorphic      |   6517.20ms |
| nbody            | 306392.14ms |
| permute          |    178.51ms |
| polymorphic      |  22955.51ms |
| queens           |    170.06ms |
| richards         |   1263.60ms |
| sieve            |    318.29ms |
| storage          |    504.69ms |
| towers           |    204.45ms |


## -O2

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  12680.27ms |
| bounce           |    158.43ms |
| cd               |  40179.44ms |
| deltablue        |   4375.17ms |
| empty            |      3.89ms |
| global_long_name |    589.32ms |
| globals          |   3428.94ms |
| json             |    589.62ms |
| list             |     26.73ms |
| mandelbrot       | 165400.42ms |
| monomorphic      |   3912.70ms |
| nbody            | 174184.90ms |
| permute          |    140.68ms |
| polymorphic      |  13185.76ms |
| queens           |    134.58ms |
| richards         |    872.05ms |
| sieve            |    254.56ms |
| storage          |    378.02ms |
| towers           |    159.79ms |


# x86-linux

## -O0

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  17129.07ms |
| bounce           |    164.43ms |
| cd               |  57498.80ms |
| deltablue        |   3959.05ms |
| empty            |      3.60ms |
| global_long_name |    720.70ms |
| globals          |   4498.72ms |
| json             |    700.45ms |
| list             |     52.80ms |
| mandelbrot       | 221484.42ms |
| monomorphic      |   5821.07ms |
| nbody            | 229304.36ms |
| permute          |    158.13ms |
| polymorphic      |  17856.59ms |
| queens           |    143.00ms |
| richards         |   1483.77ms |
| sieve            |    252.01ms |
| storage          |    362.93ms |
| towers           |    186.42ms |


## -O1

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  16261.74ms |
| bounce           |    159.51ms |
| cd               |  53865.83ms |
| deltablue        |   3778.19ms |
| empty            |      3.65ms |
| global_long_name |    700.16ms |
| globals          |   4350.70ms |
| json             |    672.68ms |
| list             |     52.25ms |
| mandelbrot       | 208127.88ms |
| monomorphic      |   5529.36ms |
| nbody            | 218529.01ms |
| permute          |    152.96ms |
| polymorphic      |  17039.37ms |
| queens           |    138.70ms |
| richards         |   1401.44ms |
| sieve            |    247.40ms |
| storage          |    353.59ms |
| towers           |    180.38ms |


## -O2

| Benchmark        | tier1       |
|:-----------------|------------:
| all_cache_phases |  16032.45ms |
| bounce           |    158.50ms |
| cd               |  53472.04ms |
| deltablue        |   3763.60ms |
| empty            |      3.62ms |
| global_long_name |    695.23ms |
| globals          |   4316.50ms |
| json             |    669.67ms |
| list             |     49.70ms |
| mandelbrot       | 201430.67ms |
| monomorphic      |   5495.43ms |
| nbody            | 212801.26ms |
| permute          |    152.36ms |
| polymorphic      |  16697.29ms |
| queens           |    136.98ms |
| richards         |   1397.62ms |
| sieve            |    245.48ms |
| storage          |    351.27ms |
| towers           |    178.34ms |


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