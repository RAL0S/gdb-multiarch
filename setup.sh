#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/RAL0S/gdb-multiarch/releases/download/v12.1/gdb-12.1-build.tar.gz -O $RALPM_TMP_DIR/gdb-12.1-build.tar.gz
  tar xf $RALPM_TMP_DIR/gdb-12.1-build.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/gdb-12.1-build.tar.gz
  echo "source $RALPM_PKG_INSTALL_DIR/.gdbinit-gef.py" > $RALPM_PKG_INSTALL_DIR/.gdbinit

  echo "#!/bin/sh" > $RALPM_PKG_BIN_DIR/gdb-multiarch
  echo "$RALPM_PKG_INSTALL_DIR/bin/gdb -x $RALPM_PKG_INSTALL_DIR/.gdbinit \"\$@\"" >> $RALPM_PKG_BIN_DIR/gdb-multiarch
  chmod +x $RALPM_PKG_BIN_DIR/gdb-multiarch
  
  echo "This package adds the command gdb-multiarch"
}

uninstall() {
  rm $RALPM_PKG_INSTALL_DIR/.gdbinit*
  rm -rf $RALPM_PKG_INSTALL_DIR/*
  rm $RALPM_PKG_BIN_DIR/gdb-multiarch
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1