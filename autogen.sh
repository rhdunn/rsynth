#!/bin/bash

CONFIG_DIR=misc

ln -sv /usr/share/${CONFIG_DIR}/config.guess config.guess
ln -sv /usr/share/${CONFIG_DIR}/config.sub config.sub

autoheader || exit 1
