# -*- mode: ruby -*-
# vi: set ft=ruby :

 $script = <<SCRIPT

    export login="graphite"
    export password="graphite"
    export email="lrochette@electric-cloud.com"
    export VERSION=0.9.10

    set -x
    echo I am provisioning...
    date > /etc/vagrant_provisioned_at
    apt-get update
    echo "America/Los_Angeles" | sudo tee /etc/timezone
    ntpdate -u http://pool.ntp.org
    dpkg-reconfigure --frontend noninteractive tzdata

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

    cp /vagrant/files/local_settings.py /etc/graphite/local_settings.py
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

    cp /vagrant/files/graphite-carbon /etc/default/graphite-carbon
    cp /vagrant/files/carbon.conf /etc/carbon/carbon.conf
    cp /vagrant/files/storage-schemas.conf /etc/carbon/storage-schemas.conf
    cp /vagrant/files/storage-aggregation.conf /etc/carbon/storage-aggregation.conf
    service carbon-cache start

    # install and configure apache
    apt-get install -y apache2 libapache2-mod-wsgi
    a2dissite 000-default
    cp /vagrant/files/apache2-graphite.conf /etc/apache2/sites-available
    a2ensite apache2-graphite
    service apache2 reload

    #install and configure statsd
    apt-get install -y git nodejs devscripts debhelper
    cd /opt
    git clone https://github.com/etsy/statsd.git
    cd statsd
    dpkg-buildpackage
    cd ..
    service carbon-cache stop
    dpkg -i statsd*.deb
    service statsd stop

    cp /vagrant/files/localConfig.js /etc/statsd/localConfig.js
    cp /vagrant/files/storage-aggregation.conf /etc/carbon/storage-aggregation.conf
    service carbon-cache start
    service statsd       start    
SCRIPT

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"
  #config.vm.box ="hashicorp/precise64"
  config.vm.provision :shell, :inline => $script

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

   
  # Virtual box specific configuration options
  config.vm.provider "virtualbox" do |vb|
    vb.name = "graphite"
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # configure dns according with the new version of vagrant
  #  config.vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  #  config.vm.network "forwarded_port", guest:80, host:8080
  #  config.vm.network "forwarded_port", guest:2003, host:2003
  #  config.vm.network "forwarded_port", guest:8125, host:8125, protocol:"udp"

  # Assign this VM to a host only network IP, allowing you to access it
  # via the IP.
  config.vm.network :private_network, ip:  "192.168.56.20"
  config.vm.hostname = "graphite"

end
