#! /usr/bin/env bash

SCRIPT_DIR=$( \cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

pushd $SCRIPT_DIR

if [ ! -f "$SCRIPT_DIR/.venv/bin/python" ]; then
    python3.12 -m venv .venv --prompt .
fi

source .venv/bin/activate

python pw_scrape.py
