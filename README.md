# Systemd script for CEPH object storage

**ceph-systemd-service-generator.sh** is a systemd generator (http://www.freedesktop.org/wiki/Software/systemd/Generators/) script which generates Ceph systemd unit files based on Ceph daemons present on current node. It supports multiple clusters on the same node, which generic init-script does not (see my issue http://tracker.ceph.com/issues/12466) and for that it relies on correct OSD and Mon settings in {cluster}.conf.
Unit files are based on https://github.com/ceph/ceph/tree/master/systemd with some dependency modifications.

**How it works**:
> 1. Removes everything like ceph*.service or ceph*.target under /usr/lib/systemd/system directory to ensure we are not using old services.
> 2. Scans /etc/ceph directory for ceph*.conf files, assuming that cluster name will start with "ceph". Every file found will be counted as separate cluster configuration.
> 3. For each cluster found it uses ceph-conf utility to find out what OSDs and MONs do exist on current machine.
> 4. For each cluster and daemon it creates unit files under /usr/lib/systemd/system folder. It creates ordinary service files like ceph-osd@1.service as well as generic template ceph-osd@.service. The later is handful when we start new OSDs, that are not currently in {cluster}.conf.
> 5. Adds handful {cluster}-osd.target and {cluster}-mon.target to be able to start/stop all OSD and MONs at once (analogue of old-fashion /etc/init.d/ceph start osd|mon).
> 6. Adds {cluster}.target to be able to start/stop and autostart entire {cluster}.
> 7. Places all required symlinks under /etc/systemd/system folder to automatically provide needed dependencies.

**How to install it**:
> ```This script must be placed under /usr/lib/systemd/system-generators folder. After that "systemctl daemon-reload" must be issued for systemd to execute generator script. The script gets executed every time systemd is 'daemon-reload'ed or at host boot time before any other service gets loaded (see systemd generators link above).```

**How to use it**:
Assuming cluster name is "ceph":

Start osd.1:
> ```systemctl start ceph-osd@1```

Stop mon.node1:
> ```systemctl stop ceph-mon@node1```

Start all OSDs on current host:
> ```systemctl start ceph-osd.target```

Stop all ceph daemons on current host:
> ```systemctl stop ceph.target```

Put Ceph completely to autostart:
> ```systemctl enable ceph.target
systemctl enable ceph-mon.target
systemctl enable ceph-osd.target
```
