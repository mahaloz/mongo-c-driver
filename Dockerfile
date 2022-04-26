# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang autoconf automake

## Add source code to the build stage.
ADD . /mongo
WORKDIR /mongo

RUN apt -y install libssl-dev libsasl2-dev git python
RUN python build/calc_release_version.py > VERSION_CURRENT
WORKDIR cmake-build
RUN cmake -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF ..
RUN make -j3
RUN make install
WORKDIR /mongo/src/libbson/fuzz/
RUN clang -fsanitize=fuzzer -I/usr/local/include/libbson-1.0 fuzz_test_libbson.c /usr/local/lib/libbson-1.0.so -o /fuzz_test_libbson
WORKDIR /
ENV LD_LIBRARY_PATH=/usr/local/lib/

# # Package Stage
# FROM --platform=linux/amd64 ubuntu:20.04
# 
# ## TODO: Change <Path in Builder Stage>
# COPY --from=builder /lzbench/lzbench /
# # 
