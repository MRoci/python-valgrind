FROM buildpack-deps:stretch
ARG PYTHON_VERSION=3.7.2

ENV PYTHONMALLOC malloc

WORKDIR /src

RUN set -e \
    && apt-get update && apt-get install -y  valgrind --no-install-recommends  \
    && curl "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz" > python.tgz  \
    && mkdir -p /usr/src/python \
    && tar -xzC /usr/src/python --strip-components=1 -f python.tgz \
    && rm python.tgz \
    && cd /usr/src/python \
    && ./configure \
        --with-pydebug \
        --with-valgrind \
        --without-pymalloc \
    && make -j "$(nproc)" \
    && make install \
    && find /usr/lib -type d -a -name '__pycache__' -exec rm -rf '{}' + \
    && cp Misc/valgrind-python.supp /src \
    && rm -rf /usr/src/python \
    && apt-get install -y python3-pip --no-install-recommends && rm -rf /var/lib/apt/lists/* \
    && ln -s $(which python3) /usr/local/bin/python \
    && ln -s $(which pip3) /usr/local/bin/pip

ENTRYPOINT ["bash"]
