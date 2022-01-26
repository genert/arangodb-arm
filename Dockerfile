FROM debian:sid-slim

# Setup dependencies for building ArangoDB
RUN apt-get update \
    && apt-get -y dist-upgrade \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    fish \
    git-core \
    build-essential \
    libssl-dev \
    libjemalloc-dev \
    cmake \
    python2.7 \
    gcc-10 \
    g++-10 \
    ruby-rspec \
    bundler

# Setup workdir
WORKDIR /arangodb

# Fetch ArangoDB source code, and prepare folders.
RUN git clone --single-branch --depth 1 git://github.com/arangodb/arangodb.git /arangodb
RUN cd /arangodb && mkdir -p build

RUN cd build && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DUSE_MAINTAINER_MODE=on -DUSE_OPTIMIZE_FOR_ARCHITECTURE=On -DUSE_GOOGLE_TESTS=on -DCMAKE_SYSTEM_PROCESSOR=aarch64 -DCMAKE_C_COMPILER=gcc-10 -DCMAKE_CXX_COMPILER=g++-10

RUN cd build && make install

# Cleanup
RUN apt-get autoremove -y --purge \
  build-essential \
  libssl-dev \
  libjemalloc-dev \
  cmake \
  python2.7 \
  python3 \
  gcc-10 \
  g++-10 \
  ruby-rspec \
  bundler

RUN apt-get install -y --no-install-recommends \
    libatomic1

RUN addgroup --gid 1000 arango && \
    adduser --disabled-password --gecos "" --ingroup arango --uid 1000 arango

CMD ["/usr/sbin/arangod", "-c", "/etc/arangodb3/arangod.conf"]

EXPOSE 8529

