#!/usr/bin/env bash

set -eo pipefail

[[ -n "${VERBOSE}" ]] && set -x

ssh-keygen -R master.example.com
ssh-keygen -R worker0.example.com
ssh-keygen -R worker1.example.com
ssh-keygen -R master
ssh-keygen -R worker-0
ssh-keygen -R worker-1


