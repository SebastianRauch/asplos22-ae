# VM/EPT Isolation Backend Evaluation

To facilitate the reproduction of the experiments conducted as part of the thesis
we provide Docker images that allow to repeat these experiments.
The experiments were originally conducted on a system equipped with an Intel Xeon Silver 4110 CPU 
with a base frequency of 2.1GHz (hyperthreading disabled) and 32GB of RAM.
We recommend at least 60GB of free disk space to build all the required Docker images.

The base image must first be built from [this](https://github.com/SebastianRauch/evaluation/blob/main/support/dockerfiles/Dockerfile.flexos-ae-base) dockerfile:
```
docker build --build-arg UK_KRAFT_GITHUB_TOKEN="<INSERT_VALID_TOKEN>" --tag flexos-ae-base -f Dockerfile.flexos-ae-base .
```

# Microbenchmarks
Instructions on the Microbenchmarks experiment can be found [here](https://github.com/SebastianRauch/evaluation/blob/main/experiments/microbench/README.md).

# iPerf
Instructions on the iPerf experiment can be found [here](https://github.com/SebastianRauch/evaluation/blob/main/experiments/iperf-bench/README.md).

# SQLite
Instructions on the SQLite experiment can be found [here](https://github.com/SebastianRauch/evaluation/blob/main/experiments/sqlite-bench/README.md).

# Acknowledgements

This work is based on the [FlexOS Artifact Evaluation for ASPLOS'22](https://github.com/project-flexos/asplos22-ae).
