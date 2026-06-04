#!/bin/bash
set -euo pipefail

select file in ../vars/*.sh; do
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

select file in ../hw/*.sh; do
    if [[ -n $file ]]; then
        echo "You selected: $file"
        export TARGETHW="$file"
        source $TARGETHW
        cat $TARGETHW
        break
    else
        echo "No hardware selected. Please try again."
    fi
done
