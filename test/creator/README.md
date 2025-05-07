`creator.rb` is a testing utility which allows for creating test suites. The
test suite is specified in one file, and generates `.co` files and `.expect`
for the expected output of that program. The format is

```
<preamble>
--
<preamble output>
==
<test1>
--
<expected results of test1>
--
<test 2>
--
<expected 2>
--
...
--
```

`<preamble>` is prepended to every file in the test suite, and `<preamble output>`
is prepended to the expected output file.

After generating the tests, use `export.sh` to move them into the proper
folders, and run them using `run_tests.sh`.
