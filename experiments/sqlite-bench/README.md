# SQLite Performance Comparison

## Overview

Time to perform 5000 INSERT queries with SQLite on Unikraft, FlexOS, Linux, SeL4
(with the Genode system). 

## Produce Measurements
Build docker image and run it:
```
docker build --build-arg UK_KRAFT_GITHUB_TOKEN="<INSERT_VALID_TOKEN>" --tag flexos-sqlite -f flexos-sqlite.dockerfile .
docker run --privileged --security-opt seccomp:unconfined -ti flexos-sqlite bash
```

Start `/root/run.sh` script and give it two isolated CPUs:
```
/root/run.sh <ISOL_CPU1> <ISOL_CPU2>
```

Extract file containing the processed measurement data at `/root/data/summary.dat`:
```
docker cp <CONTAINER-ID>:/root/data/summary.dat <PATH/ON/HOST>/summary.dat
```

## Plot
Feed the measurement data to the plot script:
```
plot.sh <PATH/ON/HOST>/summary.dat gnuplot.script <out.svg>
```
