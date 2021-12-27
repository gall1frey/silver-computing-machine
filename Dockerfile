FROM scratch
ADD ubuntu-focal-oci-amd64-root.tar.gz /

WORKDIR /project

RUN apt-get update
RUN apt-get install bash
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y g++-mingw-w64-x86-64
RUN apt-get install -y g++
RUN apt-get install gnuradio
RUN apt-get install gr-osmosdr

COPY . .

CMD ["/bin/bash"]
