# build with:
# $ docker build --build-arg UK_KRAFT_GITHUB_TOKEN="<TOKEN>" --tag flexos-nginx -f flexos-nginx.dockerfile .
#
# run with:
# $ docker run --privileged --security-opt seccomp:unconfined -ti flexos-nginx bash
#
# (--security-opt seccomp:unconfined to limit docker overhead)

FROM flexos-ae-base:latest

ARG UK_KRAFT_GITHUB_TOKEN=
ENV UK_KRAFT_GITHUB_TOKEN=${UK_KRAFT_GITHUB_TOKEN}

# install wrk for benchmarking
RUN echo "deb http://ftp.debian.org/debian buster-backports main" >> /etc/apt/sources.list && \
	 apt-get update && apt-get install -y wrk
RUN apt-get install -y gdb

COPY docker-data/nginx.cpio /root/nginx.cpio
COPY docker-data/kraftrc.nginx /root/.kraftrc
COPY docker-data/kraftcleanup.sh /usr/local/bin/kraftcleanup
RUN chmod +x /usr/local/bin/kraftcleanup

WORKDIR /root/.unikraft/apps

# build with fcalls
RUN kraftcleanup
RUN cd /root/.unikraft/unikraft && git checkout 7b28ecd560e609b07a7fe414403ff75363f027b4
COPY docker-data/configs/nginx-flexos-fcalls.config /root/.unikraft/apps/nginx/.config
COPY docker-data/configs/kraft.yaml.fcalls /root/.unikraft/apps/nginx/kraft.yaml
RUN cd nginx && make prepare && kraft -v build --no-progress --fast --compartmentalize
RUN mv /root/.unikraft/apps/nginx /root/.unikraft/apps/nginx-fcalls
COPY docker-data/start-scripts/kvm-start.sh /root/.unikraft/apps/nginx-fcalls/kvm-start.sh
COPY docker-data/start-scripts/dbg-kvm-start.sh /root/.unikraft/apps/nginx-fcalls/dbg-kvm-start.sh
COPY docker-data/start-scripts/debug.sh /root/.unikraft/apps/nginx-fcalls/debug.sh
RUN chmod +x /root/.unikraft/apps/nginx-fcalls/kvm-start.sh && \
	chmod +x /root/.unikraft/apps/nginx-fcalls/dbg-kvm-start.sh && \
	chmod +x /root/.unikraft/apps/nginx-fcalls/debug.sh

WORKDIR /root/.unikraft/apps

# build with mpk and 2 compartments (lwip/rest)
#RUN kraftcleanup
#RUN cd /root/.unikraft/unikraft && git checkout 7b28ecd560e609b07a7fe414403ff75363f027b4
#COPY docker-data/configs/nginx-flexos-mpk2.config /root/.unikraft/apps/nginx/.config
#COPY docker-data/configs/kraft.yaml.mpk2 /root/.unikraft/apps/nginx/kraft.yaml
#RUN cd nginx && make prepare && kraft -v build --no-progress --fast --compartmentalize
#RUN mv /root/.unikraft/apps/nginx /root/.unikraft/apps/nginx-mpk2
#COPY docker-data/start-scripts/kvm-start.sh /root/.unikraft/apps/nginx-mpk2/kvm-st

#RUN mv /root/.unikraft /root/flexos

WORKDIR /root
# copy run scripts
COPY docker-data/run.sh /root/run.sh
RUN chmod +x /root/run.sh
