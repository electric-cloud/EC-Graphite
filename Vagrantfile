# -*- mode: ruby -*-
# vi: set ft=ruby :

 $script = <<SCRIPT

    export login="graphite"
    export password="graphite"
    export email="lrochette@electric-cloud.com"
    export VERSION=0.9.12

    set -x
    echo I am provisioning...
    date > /etc/vagrant_provisioned_at
    apt-get update
    echo "America/Los_Angeles" | sudo tee /etc/timezone
    ntpdate -u http://pool.ntp.org
    dpkg-reconfigure --frontend noninteractive tzdata

    # install the needed package
    echo "Install Required packages"
    apt-get install -y apache2
    apt-get install -y erlang-os-mon
    apt-get install -y erlang-snmp
    apt-get install -y expect
    apt-get install -y libapache2-mod-python
    apt-get install -y libapache2-mod-wsgi
    apt-get install -y memcached
    apt-get install -y python-cairo-dev
    apt-get install -y python-dev
    apt-get install -y python-ldap
    apt-get install -y python-memcache
    apt-get install -y python-pip
    apt-get install -y python-pysqlite2
    apt-get install -y sqlite3


    # We will use python-setuptool's "easy_install" utility to install a few more important python components:
    pip install carbon # ==$VERSION
    pip install graphite-web # ==$VERSION
    pip install whisper # ==$VERSION
    pip install Twisted # ==11.1.0
    pip install django # ==1.5
    pip install django-tagging # ==0.3.1


    # configure Graphite
    cp /vagrant/files/carbon.conf /opt/graphite/conf
    cp /vagrant/files/storage-schemas.conf /opt/graphite/conf

    cd /opt/graphite/webapp/graphite
    python manage.py syncdb --noinput
    python manage.py createsuperuser --username="${login}" --email="${email}" --noinput
    expect << DONE
        spawn python manage.py changepassword "${login}"
        expect "Password: "
        send -- "${password}\r"
        expect "Password (again): "
        send -- "${password}\r"
        expect eof
DONE

    cp /vagrant/files/local_settings.py /opt/graphite/webapp/graphite

    # Configure apache
    echo "Configuring Apache"
    cp /vagrant/files/graphite-vhost.conf /etc/apache2/sites-available/default
    cp /vagrant/files/graphite.wsgi /opt/graphite/conf/graphite.wsgi
    chown -R www-data:www-data /opt/graphite/storage
    mkdir -p /etc/httpd/wsgi
    service apache2 restart

    # statsd
    echo "Install and configure statsd"
    apt-get -y install python-software-properties
    apt-add-repository -y ppa:chris-lea/node.js
    apt-get update
    apt-get install -y nodejs

    # install git and clone statsd
    apt-get install -y git
    cd /opt
    git clone git://github.com/etsy/statsd.git
    cp /vagrant/files/localConfig.js /opt/statsd/localConfig.js

    # Start Services
    /opt/graphite/bin/carbon-cache.py start
    cd /opt/statsd
    node ./stats.js ./localConfig.js  &

SCRIPT

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "hashicorp/precise64"
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
