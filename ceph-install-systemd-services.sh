#!/bin/bash
cp -f ceph-systemd-service-generator.sh /usr/lib/systemd/system-generators/
systemctl daemon-reload
