#!/bin/sh

set -e

base="$(readlink -f "$0")"

lxc stop --force database-test 2>/dev/null || true
lxc delete database-test 2>/dev/null || true
lxc launch ubuntu:20.10 database-test
lxc config device add database-test source disk source=`pwd` path=/mnt/source
lxc restart database-test
for i in $(seq 10); do
	if lxc exec database-test -- ping -c 1 www.google.com; then
		break
	fi
	sleep 1
done
lxc exec database-test -- systemctl isolate default
lxc exec database-test -- useradd -m user
echo 'user ALL=(ALL) NOPASSWD:ALL' | lxc exec database-test -- tee /etc/sudoers.d/user
lxc exec database-test -- sudo -u user -i git clone /mnt/source database-test
lxc exec database-test -- sudo -u user -i database-test/setup-database-test.sh
lxc exec database-test -- sudo -u user -i database-test/database-test.sh
lxc stop database-test
lxc delete database-test
