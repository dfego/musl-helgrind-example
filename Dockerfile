FROM ubuntu:22.04

ARG PACKAGES

# Install packages
RUN apt-get update \
    && apt-get install -y \
    curl \
    build-essential \
    valgrind \
    ${PACKAGES}

WORKDIR /musl
ENV MUSL_TAR="musl-1.2.3.tar.gz"
RUN curl https://www.musl-libc.org/releases/${MUSL_TAR} -o /${MUSL_TAR}
RUN tar -xzf /${MUSL_TAR} --strip-components 1 \
    && ./configure --prefix=/usr/local \
    && make -j 5 \
    && make install \
    && rm -rf *
