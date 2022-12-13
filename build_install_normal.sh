#!/bin/bash
set -x
set -euo pipefail

openssl_tag="OpenSSL_1_1_1s"
openssl_folder="openssl-1.1.1s"
openssl_install="/opt"

OPENSSL_TAG="${openssl_tag}"
OPENSSL_ROOT="${openssl_install}/${openssl_folder}"
OPENSSL_FOLDER="${openssl_folder}"

git clone --depth 1 https://github.com/openssl/openssl.git -b ${OPENSSL_TAG} --recursive --shallow-submodules && \
    cd openssl && \
    ./config --prefix="${OPENSSL_ROOT}" --openssldir="${OPENSSL_ROOT}" && \
    make -j$(nproc) && \
    make install && \
    mv /usr/bin/openssl /usr/bin/openssl.old && \
    ln -s "${OPENSSL_ROOT}/bin/openssl" /usr/bin/openssl && \
    mv /usr/bin/c_rehash /usr/bin/c_rehash.old && \
    ln -s "${OPENSSL_ROOT}/bin/c_rehash" /usr/bin/c_rehash  && \
    echo "${OPENSSL_ROOT}/lib" | tee /etc/ld.so.conf.d/${OPENSSL_FOLDER}.conf && \
    ldconfig -v && \
    mv "${OPENSSL_ROOT}/certs" "${OPENSSL_ROOT}/certs.old" && \
    ln -s /etc/ssl/certs "${OPENSSL_ROOT}" && \
    cd .. && \
    rm -fr /tmp/work