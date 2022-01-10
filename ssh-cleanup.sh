#!/usr/bin/env bash

set -eo pipefail

[[ -n "${VERBOSE}" ]] && set -x

ssh-keygen -R 192.168.193.20
ssh-keygen -R 192.168.193.30
ssh-keygen -R 192.168.193.31
