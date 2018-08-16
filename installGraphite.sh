export login="graphite"
export password="graphite"
export email="lrochette@electric-cloud.com"
export VERSION=0.9.10

STARTINGDIR=$PWD

set -x
echo I am provisioning...
#date > /etc/vagrant_provisioned_at
apt-get update
echo "America/Los_Angeles" | sudo tee /etc/timezone
ntpdate -u http://pool.ntp.org
dpkg-reconfigure --frontend noninteractive tzdata

# Remove apparmor
/etc/init.d/apparmor stop
apt-get --purge remove -y apparmor apparmor-utils libapparmor-perl libapparmor1

# install the needed package
echo "Install Required packages"
apt-get install -y graphite-web graphite-carbon

# install and configure DB
apt-get install -y postgresql libpq-dev python-psycopg2
apt-get install -y expect
sudo -u postgres psql << DB
CREATE USER graphite WITH PASSWORD 'graphite';
CREATE DATABASE graphite WITH OWNER graphite;
DB

cp $STARTINGDIR/files/local_settings.py /etc/graphite/local_settings.py
graphite-manage migrate auth
graphite-manage syncdb --noinput
graphite-manage createsuperuser --username="${login}" --email="${email}" --noinput
expect << DONE
spawn graphite-manage changepassword "${login}"
expect "Password: "
send -- "${password}\r"
expect "Password (again): "
send -- "${password}\r"
expect eof
DONE

cp $STARTINGDIR/files/graphite-carbon /etc/default/graphite-carbon
cp $STARTINGDIR/files/carbon.conf /etc/carbon/carbon.conf
cp $STARTINGDIR/files/storage-schemas.conf /etc/carbon/storage-schemas.conf
cp $STARTINGDIR/files/storage-aggregation.conf /etc/carbon/storage-aggregation.conf
service carbon-cache start

# install and configure apache
apt-get install -y apache2 libapache2-mod-wsgi
a2dissite 000-default
cp $STARTINGDIR/files/apache2-graphite.conf /etc/apache2/sites-available
a2ensite apache2-graphite
service apache2 reload

#install and configure statsd
apt-get -y -f install
apt-get install -y npm dh-systemd git nodejs nodejs-legacy devscripts debhelper 
cd /opt
git clone https://github.com/etsy/statsd.git
cd statsd
dpkg-buildpackage
cd ..
service carbon-cache stop
dpkg -i statsd*.deb
service statsd stop

cp $STARTINGDIR/files/localConfig.js /etc/statsd/localConfig.js
cp $STARTINGDIR/files/storage-aggregation.conf /etc/carbon/storage-aggregation.conf
service carbon-cache start
service statsd       start

# Install Grafana
cd
wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_5.1.4_amd64.deb
sudo apt-get install -y adduser libfontconfig
sudo dpkg -i grafana_5.1.4_amd64.deb
sudo /bin/systemctl start grafana-server
