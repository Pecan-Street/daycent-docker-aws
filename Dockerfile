# DayCent + List100 pipeline
# binaries provided by Dr. Trung Nguyen, Thank you!

# start by building the basic container
FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV GLIBC_VER=2.31-r0

MAINTAINER Steve Mock<smock@pecanstreet.org>
RUN apt update -y && apt-get upgrade -y

# add gfortran, debugging tools and make
RUN apt update -y && apt-get upgrade -y
# add gfortran, debugging tools and make
RUN apt install -y gfortran gdb make
RUN apt install -y awscli 
RUN apt install -y unzip

# make the working dirs
RUN mkdir /daycent


# add the 2 DayCent binaries provided by Dr. Nguyen
ADD ./bin/DayCent /daycent/DayCent
ADD ./bin/list100 /daycent/list100
WORKDIR /daycent

RUN chmod +x DayCent && chmod +x list100

# copy the entrypoint bash script in
COPY entrypoint.sh /daycent/entrypoint.sh
RUN chmod +x /daycent/entrypoint.sh

# add aws creds
ADD aws /root/.aws

ENTRYPOINT ["/daycent/entrypoint.sh"]

