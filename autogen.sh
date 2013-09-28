#!/bin/bash

CONFIG_DIR=misc

ln -svf /usr/share/${CONFIG_DIR}/config.guess config.guess
ln -svf /usr/share/${CONFIG_DIR}/config.sub config.sub

autoheader || exit 1
