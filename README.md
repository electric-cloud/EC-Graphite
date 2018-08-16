EC-Graphite
===========

## Vagrant Installation
A Vagrant VM to setup a statsd and graphite environment. The box has been build following the directions at 
	https://www.digitalocean.com/community/tutorials/how-to-configure-statsd-to-collect-arbitrary-stats-for-graphite-on-ubuntu-14-04


The VM created has a default address of 192.168.56.20 and is named graphite

## Ubuntu Installation
(Enter yes at the prompt.  TODO: automate this)
```
git clone https://github.com/electric-cloud/EC-Graphite.git
cd EC-Graphite
sudo ./installGraphite.sh
```

The user/password for the Graphite DB is graphite/graphite

When your graphite Vagrant box is up, do not forget to modify the wrapper.conf on your commander server (minimum version is 5.0.1).

Uncomment the following lines and be sure to point to your statsd/graphite
machine.

```
# These are for enabling Commander to send data to a statsd server. 
# Only the hostname is required, the other options are included to show 
# the default values.
wrapper.java.additional.800=-DCOMMANDER_STATSD_HOST=statsd
wrapper.java.additional.801=-DCOMMANDER_STATSD_PORT=8125
wrapper.java.additional.802=-DCOMMANDER_STATSD_PREFIX=commander
wrapper.java.additional.803=-DCOMMANDER_STATSD_INCLUDE_HOSTNAME=true
```
