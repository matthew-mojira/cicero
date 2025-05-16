# Testing

Testing cicero is done by running cicero programs and comparing text output
with expected results.

## Test suites

Test suites are in the `suites` subdirectory. Each file defines one or more
tests, which the testing script separates during testing.

Each file begins with *common code*, which defines code to be inserted at the
beginning of each test:

```
<common code>
--
<expected output of common code>
==
```

If there is no common code, the first line can simply be `==`.

After common code is each test, which looks like:

```
<test code>
--
<expected output of test code>
--
```

## Running tests

Run tests using the `run_tests.sh` script. By default it runs all suites for
all targets on all tiers, but you can narrow it down with the following
environment variables:
* `TEST_SUITES`: which files from the `script` directory to separate and test
* `TEST_TARGETS`: which targets to test
* `TEST_TIERS`: which tiers to test
