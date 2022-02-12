# You can easily build it with the following command:
# $ docker build --build-arg UK_KRAFT_GITHUB_TOKEN="<YOUR TOKEN>" --tag flexos-microbench -f flexos-microbench.dockerfile .
#
# and run with:
# $ docker run --privileged --security-opt seccomp:unconfined -ti flexos-microbench bash
#
# (--security-opt seccomp:unconfined to limit docker overhead)

FROM flexos-ae-base:latest

ARG UK_KRAFT_GITHUB_TOKEN=
ENV UK_KRAFT_GITHUB_TOKEN=${UK_KRAFT_GITHUB_TOKEN}

##############
# FlexOS (KVM)

WORKDIR /root/.unikraft

# build microbenchmarks for EPT
RUN kraftcleanup
COPY docker-data/configs/microbenchmarks-flexos-ept.config apps/flexos-microbenchmarks/.config
COPY docker-data/configs/kraft.yaml.ept apps/flexos-microbenchmarks/kraft.yaml
COPY docker-data/vfscore-extra.ld unikraft/lib/vfscore/extra.ld

WORKDIR /root/.unikraft/apps
RUN cd /root/.unikraft/unikraft && git fetch && git checkout 20e1c198d4b320343c2876a466c151389f23edcf
RUN cd flexos-microbenchmarks && git checkout 8f4dbab94ebbf3d53558f3a42979fb3858632841
RUN cd /root/.unikraft/libs/flexos-microbenchmarks && git checkout 7242c3ebb015244926c0c4dd442e4a6038e97fbf
RUN cd flexos-microbenchmarks && make prepare && kraft -v build --fast --compartmentalize
RUN mkdir flexos-microbenchmarks/images
RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64.comp0 flexos-microbenchmarks/images/microbench_ept.comp0
RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64.comp1 flexos-microbenchmarks/images/microbench_ept.comp1
# change to lower bound measurements
RUN sed -i 's/#define MODE MODE_REMOTECALL/#define MODE MODE_RPC_LOWER_BOUND/g' flexos-microbenchmarks/main.c 
RUN cd flexos-microbenchmarks && make prepare && kraft -v build --fast --compartmentalize
RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64.comp0 flexos-microbenchmarks/images/lower_bounds.comp0
RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64.comp1 flexos-microbenchmarks/images/lower_bounds.comp1
RUN mv flexos-microbenchmarks flexos-microbenchmarks-ept

WORKDIR /root/.unikraft

# build microbenchmarks for MPK
RUN kraftcleanup

COPY docker-data/configs/microbenchmarks-flexos-mpk.config apps/flexos-microbenchmarks/.config
COPY docker-data/configs/kraft.yaml.mpk apps/flexos-microbenchmarks/kraft.yaml
COPY docker-data/vfscore-extra.ld unikraft/lib/vfscore/extra.ld

WORKDIR /root/.unikraft/apps
RUN cd flexos-microbenchmarks && git checkout 8f4dbab94ebbf3d53558f3a42979fb3858632841
RUN cd /root/.unikraft/libs/flexos-microbenchmarks && git checkout 7242c3ebb015244926c0c4dd442e4a6038e97fbf
RUN cd flexos-microbenchmarks && make prepare && kraft -v build --fast --compartmentalize
RUN mkdir flexos-microbenchmarks/images
RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64 flexos-microbenchmarks/images/microbench_mpk
RUN mv flexos-microbenchmarks flexos-microbenchmarks-mpk

COPY docker-data/start-scripts/kvmflexosept-start.sh flexos-microbenchmarks-ept/kvm-start.sh
COPY docker-data/start-scripts/kvmflexos-start.sh flexos-microbenchmarks-mpk/kvm-start.sh

WORKDIR /root
RUN mkdir linux_syscall
COPY docker-data/syscall_test.c linux_syscall/syscall_test.c
RUN cd linux_syscall && gcc -O2 -o syscall-test syscall_test.c -lm

WORKDIR /root
COPY docker-data/run.sh run.sh
RUN chmod +x run.sh
