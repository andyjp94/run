FROM ubuntu:16.04

RUN apt update && apt install -y jq shellcheck git &&\
    git clone https://github.com/bats-core/bats-core.git &&\
    cd bats-core &&\
    ./install.sh /usr/local 
    
    
RUN apt install -y binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev python cmake gcc build-essential && git clone https://github.com/SimonKagstrom/kcov.git /opt/kcov &&\
    cd /opt/kcov &&\
    mkdir build &&\
    cd build &&\
    export CXX=/usr/bin/gcc &&\
    cmake .. &&\
    make &&\
    make install

ADD src /root/src
ADD test /root/test
WORKDIR /root/test
ENV LOC "./run.json"


CMD ["/bin/sh", "-c", "./local_runner.bats"]