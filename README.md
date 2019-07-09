Duplicity Backup
================

My personal NAS backup script. Runs on a Raspberry Pi and backs up a Synology NAS with Samba shares. Uses Duplicity, Backblaze B2, and GPG encryption.

Dependencies
------------

Beside duplicity, requires python and the b2 package from pip.

Usage
-----

1. Run [install.sh][1].
2. Add [run.sh][2] to your crontab

Up Next
-------

* Add support for healthchecks.io
* Make idempotent using `mountpoint` command
* Improve this README with links, more specific instructions.

[1]: install.sh
[2]: run.sh