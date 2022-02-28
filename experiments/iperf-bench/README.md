# iPerf throughput

## Overview

Network throughput (iPerf) with Unikraft, FlexOS with the MPK backend and 
FlexOS with the VM/EPT backend.

## Produce Measurements
Build docker image and run it:
```
docker build --build-arg UK_KRAFT_GITHUB_TOKEN="<INSERT_VALID_TOKEN>" --tag flexos-iperf -f flexos-iperf.dockerfile .
docker run --privileged --security-opt seccomp:unconfined -ti flexos-iperf bash
```

Start `/root/run.sh` script and give it two isolated CPUs:
```
/root/run.sh <ISOL_CPU1> <ISOL_CPU2> <ISOL_CPU3> <NO_ISOL_CPU1> <NO_ISOL_CPU2> <NO_ISOL_CPU3> <NO_ISOL_CPU4>
```

Extract file containing the processed measurement data located at `/out/results/iperf.dat`:
```
docker cp <CONTAINER-ID>:/out/results/iperf.dat <PATH/ON/HOST>/iperf.dat
```

## Plot
Feed the measurement data to the plot script:
```
plot.sh <PATH/ON/HOST>/iperf.dat gnuplot.script <out.pdf>
```
