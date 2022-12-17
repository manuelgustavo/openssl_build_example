#!/bin/bash
set -x
reset_sudo()
{
if [ $SUDOCREDCACHED != 0 ] ; then 
  # drop credentials if acquired in script
  sudo -k
fi
}

Ctrl_C()
{
  reset_sudo
  exit 0
}

sudo -nv 2> /dev/null
SUDOCREDCACHED=$?
if [ $SUDOCREDCACHED != 0 ] ; then 
  # acquire credentials
  sudo -v 
  if [ $? != 0 ] ; then 
    exit 1
  fi
fi

trap Ctrl_C SIGINT
#####################
set -euo pipefail

openssl_tag="OpenSSL_1_1_1s"
openssl_folder="openssl-1.1.1s"
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
    ./config --prefix="${OPENSSL_ROOT}" --openssldir="${OPENSSL_ROOT}"
    make -j$(nproc)
    sudo rm -fr "${OPENSSL_ROOT}"
    sudo make install
    sudo rm -fr /usr/bin/openssl.old
    sudo mv /usr/bin/openssl /usr/bin/openssl.old
    sudo ln -s "${OPENSSL_ROOT}/bin/openssl" /usr/bin/openssl
    sudo rm -fr /usr/bin/c_rehash.old
    sudo mv /usr/bin/c_rehash /usr/bin/c_rehash.old
    sudo ln -s "${OPENSSL_ROOT}/bin/c_rehash" /usr/bin/c_rehash
    sudo rm -fr /etc/ld.so.conf.d/openssl*
    echo "${OPENSSL_ROOT}/lib" | sudo tee /etc/ld.so.conf.d/${OPENSSL_FOLDER}.conf
    sudo ldconfig -v
    sudo rm -fr "${OPENSSL_ROOT}/certs.old"
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
    reset_sudo
}

main "$@"