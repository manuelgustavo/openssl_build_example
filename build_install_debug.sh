#!/bin/bash
set -x
set -euo pipefail

openssl_tag="OpenSSL_1_1_1s"
openssl_folder="openssl-1.1.1s-debug"
openssl_install="/opt"

OPENSSL_TAG="${openssl_tag}"
OPENSSL_ROOT="${openssl_install}/${openssl_folder}"
OPENSSL_FOLDER="${openssl_folder}"

install_openssl()
{
    echo "Remember to cleanup /etc/ld.so.conf.d/ for any previous openssl configuration!"
    echo "Installing ${openssl_tag} with DEBUG symbols..."
    rm -fr "${openssl_folder}"
    mkdir "${openssl_folder}"
    cd "${openssl_folder}"
    git clone --depth 1 https://github.com/openssl/openssl.git -b ${OPENSSL_TAG} --recursive --shallow-submodules .
    ./config -d --prefix="${OPENSSL_ROOT}" --openssldir="${OPENSSL_ROOT}"
    make -j$(nproc)
    sudo make install
    sudo mv /usr/bin/openssl /usr/bin/openssl.old
    sudo ln -s "${OPENSSL_ROOT}/bin/openssl" /usr/bin/openssl
    sudo mv /usr/bin/c_rehash /usr/bin/c_rehash.old
    sudo ln -s "${OPENSSL_ROOT}/bin/c_rehash" /usr/bin/c_rehash
    echo "${OPENSSL_ROOT}/lib" | sudo tee /etc/ld.so.conf.d/${OPENSSL_FOLDER}.conf
    sudo ldconfig -v
    sudo mv "${OPENSSL_ROOT}/certs" "${OPENSSL_ROOT}/certs.old"
    sudo ln -s /etc/ssl/certs "${OPENSSL_ROOT}"
    echo .
    echo .
    echo .
    echo "${openssl_tag} with DEBUG symbols INSTALLED!"
}


main()
{
    install_openssl
}

main "$@"