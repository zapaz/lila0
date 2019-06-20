FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    apt-utils aptitude openssh-server supervisor git \
    cmake g++ libboost-all-dev libopenblas-dev opencl-headers \
    ocl-icd-libopencl1 ocl-icd-opencl-dev zlib1g-dev qt5-default qt5-qmake

RUN git clone https://github.com/leela-zero/leela-zero /src
WORKDIR /src
RUN git submodule update --init --recursive

WORKDIR /src/build/
RUN CXX=g++ CC=gcc cmake -DUSE_CPU_ONLY=1 ..
RUN cmake --build . --target leelaz --config Release -- -j2
RUN mv leelaz /usr/local/bin

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh
COPY keys.pub /root/.ssh/authorized_keys
COPY sshd.conf /etc/supervisor/conf.d/sshd.conf

ADD http://zero.sjeng.org/best-network /root/.local/share/leela-zero/best-network

EXPOSE 22
CMD ["/usr/bin/supervisord", "-n"]