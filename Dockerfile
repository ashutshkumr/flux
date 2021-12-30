FROM ubuntu:20.04
ENV FLUX_ROOT=/home/flux
RUN apt-get install -y sudo && mkdir -p ${FLUX_ROOT}
COPY . ${FLUX_ROOT}/
RUN cd ${FLUX_ROOT} && ./do.sh install_deps 2>&1
WORKDIR ${FLUX_ROOT}
CMD ["/bin/bash"]
