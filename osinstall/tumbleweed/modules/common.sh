#!/bin/bash
set -euo pipefail

# set vars globally on system
cp $TARGETVARS /etc/profile.d/vars.sh
chmod 644 /etc/profile.d/vars.sh

