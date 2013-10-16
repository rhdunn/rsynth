#!/bin/bash

CONFIG_DIR=misc

ln -svf /usr/share/${CONFIG_DIR}/config.guess config.guess
ln -svf /usr/share/${CONFIG_DIR}/config.sub config.sub

autoheader || exit 1

# NOTE: rsynth configure.ac does not work with autoconf 2.69.
autoconf2.59 || exit 1
