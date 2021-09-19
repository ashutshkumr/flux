FROM ubuntu:20.04
ENV GOPATH=/home/go
ENV PATH=${PATH}:/usr/local/go/bin:/home/go/bin
ENV FLUX_ROOT=/home/flux
RUN mkdir -p ${FLUX_ROOT}
COPY . ${FLUX_ROOT}/
RUN cd ${FLUX_ROOT} && chmod +x ./do.sh && ./do.sh deps 2>&1
WORKDIR ${FLUX_ROOT}
CMD ["/bin/bash"]