Duplicity Backup
================

My personal NAS backup script(s). Written for my own personal use, as simply as possible. This is not designed to handle any use case you could ever imagine. If it's helpful to someone else, great! This might be a good template to start from, to get your own backups up and running.

Assumptions
-----------

* Backup scripts are running on a Raspberry Pi model 3b+.
* You are backing up a several Samba network shares (only tested with a Synology NAS).
* You are saving backup data to a [Backblaze B2][1] bucket.
* You are using GPG to encrypt your backups. This backup uses _two_ keys:
    * One key is generated on the Raspberry Pi, and is only used for backup encryption, decryption, and signing. It never leaves the Raspberry Pi.
    * The other key is a super-secret offline key that you keep on a flash drive. In the event that your Raspberry Pi dies, you can still restore the backup using this key.
* You are using a service like [Heathchecks.io][2] to monitor your backup, and send you notifications if it stops running for some reason.
* You have an email address which can receive backup log emails.

Dependencies
------------

Besides duplicity, requires python, msmtp, and the b2 package from pip.

```
sudo apt install -y duplicity python-pip msmtp-mta
sudo pip install b2
```

Usage
-----

1. Run [install.sh][3].
2. Use [run.sh][4] to manually test settings and perform an initial backup. This could take a while, so you might consider running it inside `tmux` so you can log out and come back to it later.
3. Add [cronjob.sh][5] to your crontab. Use `sudo crontab -e` and add something like this to your crontab:
    ```
    # Run backup every Friday at 11 PM
    0 23 * * 5 [PATH_TO_DUPLICITY_BACKUP]/cronjob.sh >/home/[USERNAME]/cron-log.txt 2>&1
    ```

[1]: https://www.backblaze.com/b2/cloud-storage.html
[2]: https://healthchecks.io
[3]: install.sh
[4]: run.sh
[5]: cronjob.sh