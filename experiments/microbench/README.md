# Microbenchmarks

## Overview

Microbenchmarks of FlexOS MPK and VM/EPT gates and local function calls.

## Produce Measurements
Build docker image and run it:
```
docker build --build-arg UK_KRAFT_GITHUB_TOKEN="<INSERT_VALID_TOKEN>" --tag flexos-microbench -f flexos-microbench.dockerfile .
docker run --privileged --security-opt seccomp:unconfined -ti flexos-microbench bash
```

Start `/root/run.sh` script and give it two isolated CPUs:
```
/root/run.sh <ISOL_CPU1> <ISOL_CPU2>
```

Extract file containing the processed measurement data located at `/root/data/results.dat`:
```
docker cp <CONTAINER-ID>:/root/data/results.dat <PATH/ON/HOST>/results.dat
```

## Plot
Feed the measurement data to the plot script:
```
plot.sh <PATH/ON/HOST>/results.dat gnuplot.script <out.pdf>
```
