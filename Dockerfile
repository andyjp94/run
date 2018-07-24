FROM ubuntu:16.04

RUN apt update && apt install -y jq shellcheck git &&\
    git clone https://github.com/bats-core/bats-core.git &&\
    cd bats-core &&\
    ./install.sh /usr/local &&\
    mkdir /etc/run
    

ADD src /root/src
ADD test /root/test
WORKDIR /root/test
ENV LOC "./run.json"


ENTRYPOINT ["/bin/sh", "-c", "./local_runner.bats"]
CMD ["./local_runner.bats"]