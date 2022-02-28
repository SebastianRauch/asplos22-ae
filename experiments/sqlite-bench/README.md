# SQLite Performance Comparison

## Overview

Time to perform 5000 INSERT queries with SQLite on Unikraft, 
FlexOS with the MPK and VM/EPT backends, Linux, SeL4 (with the Genode system). 

## Produce Measurements
Build docker image and run it:
```
docker build --build-arg UK_KRAFT_GITHUB_TOKEN="<INSERT_VALID_TOKEN>" --tag flexos-sqlite -f flexos-sqlite.dockerfile .
docker run --privileged --security-opt seccomp:unconfined -ti flexos-sqlite bash
```

Start `/root/run.sh` script and give it two isolated CPUs:
```
/root/run.sh <ISOL_CPU1> <ISOL_CPU2> <ISOL_CPU3> <NO_ISOL_CPU1> <NO_ISOL_CPU2> <NO_ISOL_CPU3> <NO_ISOL_CPU4>
```

Extract file containing the processed measurement data located at `/out/results/sqlite.dat`:
```
docker cp <CONTAINER-ID>:/out/results/sqlite.dat <PATH/ON/HOST>/sqlite.dat
```

## Plot
Feed the measurement data to the plot script:
```
plot.sh <PATH/ON/HOST>/sqlite.dat gnuplot.script <out.pdf>
```
