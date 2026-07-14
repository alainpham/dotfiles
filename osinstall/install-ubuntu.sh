#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo script directory : $SCRIPT_DIR
select file in "$SCRIPT_DIR/../vars/"*.sh; do
    if [[ -n "$file" ]]; then
        echo "You selected: $file"
        export TARGETVARS=$file
        source $TARGETVARS
        cat $TARGETVARS
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

select file in "$SCRIPT_DIR/../hw/"*.sh; do
    if [[ -n $file ]]; then
        echo "You selected: $file"
        export TARGETHW="$file"
        cat $TARGETHW
        break
    else
        echo "No hardware selected. Please try again."
    fi
done

echo "running common.sh"
bash "/home/$TARGET_USERNAME/dotfiles/osinstall/tumbleweed/modules/common.sh"
source /etc/profile.d/vars.sh
source /etc/profile.d/sources.sh
