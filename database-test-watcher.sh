#!/bin/sh

base="$(dirname "$(readlink -f "$0")")"

cd "${base}"

./database-test.sh
while inotifywait --exclude '.*(~|\.swp)' --event CLOSE_WRITE -r sql tests; do
	./database-test.sh
done
