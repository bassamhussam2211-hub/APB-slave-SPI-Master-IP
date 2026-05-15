# SPI Master UVM Verification Environment

This folder is the UVM implementation of the SPI master verification project.

Run with Questa:

```sh
make clean
make compile
make run TEST=sanity_test SEED=1
make regress REGRESSION_SEEDS=2
make cov
make run_bonus
```

Manual Questa flow:

```tcl
do run.do
```

The environment includes APB and SPI agents, a UVM register block, RAL adapter, virtual sequences, scoreboard, coverage subscriber, and SVA binds into the exposed DUT hierarchy.
