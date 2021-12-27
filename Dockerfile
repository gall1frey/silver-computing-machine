FROM scratch
ADD ubuntu-focal-oci-amd64-root.tar.gz /

WORKDIR /project

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install bash
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y g++-mingw-w64-x86-64
RUN apt-get install -y g++
RUN apt-get install -y gnuradio
RUN apt-get install -y gr-osmosdr

COPY . .

CMD ["/bin/bash"]
