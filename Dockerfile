# Docker file for gitlab CI test image

FROM centos:7.8.2003

MAINTAINER Paul van der Laan <plaa@dtu.dk>

ENV SHELL /bin/bash
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
ENV CONDA_ENV_PATH /opt/miniconda
ENV PATH $CONDA_ENV_PATH/bin:$PATH

RUN yum -y update; yum clean all \
 && yum install -y -q \
    tar \
    wget \
    bzip2 \
    gcc-gfortran \
    git-all \
    curl \
    gcc gcc-c++ make openssl-devel

# gcc7
RUN yum -y install centos-release-scl
RUN yum -y install devtoolset-7
RUN /usr/bin/scl enable devtoolset-7 bash

# add devtoolset to PATH and LD_LIBRARY_PATH
ENV PATH=/opt/rh/devtoolset-7/root/usr/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH /opt/rh/devtoolset-7/root/usr/lib64

# openmpi
RUN wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.4.tar.gz \
  && tar -xzf openmpi-4.0.4.tar.gz \
  && cd openmpi-4.0.4 \
  && ./configure --prefix=/usr/local \
  && make all install

# Install miniconda to /miniconda
RUN wget --quiet \
    https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh && \
    bash Miniconda-latest-Linux-x86_64.sh -b -p $CONDA_ENV_PATH && \
    rm Miniconda-latest-Linux-x86_64.sh && \
    chmod -R a+rx $CONDA_ENV_PATH
RUN conda update --quiet --yes conda \
  && conda create -y -n py36 python=3.6 \
  && /bin/bash -c "source activate py36 \
  && conda install pip numpy scipy xarray nose mpi4py"
