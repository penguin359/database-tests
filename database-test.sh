#!/bin/sh

set -e

base="$(dirname "$(readlink -f "$0")")"

cd "${base}"

pg_prove tests/*.sql
