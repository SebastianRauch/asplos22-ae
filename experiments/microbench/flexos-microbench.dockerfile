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
RUN cd flexos-microbenchmarks && git checkout db371a74930a7182bdaa62b0b5051428ddf634c0
RUN cd /root/.unikraft/libs/flexos-microbenchmarks && git checkout 96d3359d32497ca4e271ae94a7b9987e67853ea7
RUN cd flexos-microbenchmarks && make prepare && kraft -v build --fast --compartmentalize
RUN mkdir flexos-microbenchmarks/images
RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64.comp0 flexos-microbenchmarks/images/microbench_ept_serialize_rdtsc.comp0
RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64.comp1 flexos-microbenchmarks/images/microbench_ept_serialize_rdtsc.comp1
RUN sed -i 's/#define SERIALIZE_RDTSC 1/#define SERIALIZE_RDTSC 0/g' flexos-microbenchmarks/main.c
RUN cd flexos-microbenchmarks && make prepare && kraft -v build --fast --compartmentalize
RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64.comp0 flexos-microbenchmarks/images/microbench_ept_no_serialize_rdtsc.comp0
RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64.comp1 flexos-microbenchmarks/images/microbench_ept_no_serialize_rdtsc.comp1
RUN sed -i 's/APPFLEXOSMICROBENCHMARKS_SRCS-y += $(APPFLEXOSMICROBENCHMARKS_BASE)\/main.c/#APPFLEXOSMICROBENCHMARKS_SRCS-y += $(APPFLEXOSMICROBENCHMARKS_BASE)\/main.c/g' flexos-microbenchmarks/Makefile.uk
RUN sed -i 's/#APPFLEXOSMICROBENCHMARKS_SRCS-y += $(APPFLEXOSMICROBENCHMARKS_BASE)\/rpc_lb.c/APPFLEXOSMICROBENCHMARKS_SRCS-y += $(APPFLEXOSMICROBENCHMARKS_BASE)\/rpc_lb.c/g' flexos-microbenchmarks/Makefile.uk
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
RUN cd flexos-microbenchmarks && git checkout db371a74930a7182bdaa62b0b5051428ddf634c0
RUN cd /root/.unikraft/libs/flexos-microbenchmarks && git checkout 96d3359d32497ca4e271ae94a7b9987e67853ea7
RUN cd flexos-microbenchmarks && make prepare && kraft -v build --fast --compartmentalize
RUN mkdir flexos-microbenchmarks/images

RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64 flexos-microbenchmarks/images/microbench_mpk_serialize_rdtsc
RUN sed -i 's/#define SERIALIZE_RDTSC 1/#define SERIALIZE_RDTSC 0/g' flexos-microbenchmarks/main.c
RUN cd flexos-microbenchmarks &&  make prepare && kraft -v build --fast --compartmentalize
RUN mv flexos-microbenchmarks/build/flexos-microbenchmarks_kvm-x86_64 flexos-microbenchmarks/images/microbench_mpk_no_serialize_rdtsc
RUN mv flexos-microbenchmarks flexos-microbenchmarks-mpk

COPY docker-data/start-scripts/kvmflexosept-start.sh flexos-microbenchmarks-ept/kvm-start.sh
COPY docker-data/start-scripts/kvmflexos-start.sh flexos-microbenchmarks-mpk/kvm-start.sh

WORKDIR /root
COPY docker-data/run.sh run.sh
RUN chmod +x run.sh
