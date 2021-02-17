#!/bin/bash

echo "Checking parameters"

if [ $# -eq 2 ]
  then
    echo "ok"
  else
    echo "Missing arguments"
    exit 1
fi

if ! lsof -i:8888
then
    echo "8888 is free"
else
    echo "8888 is occupied"
    exit 1
fi

echo "Installing dependencies"
apt-get install automake
apt-get install build-essential

echo "Cloning tinyproxy"
sudo git clone https://github.com/tinyproxy/tinyproxy
cd tinyproxy/
echo "ok"

echo "Compiling"
./autogen.sh
make
make install
cd ..
echo "ok"

echo "Adding tinyproxy user"
useradd -M -U -s /bin/false tinyproxy
echo "ok"

echo "Adding aux files"
mkdir -p /usr/local/var/log/tinyproxy
touch /usr/local/var/log/tinyproxy/tinyproxy.log
chown tinyproxy:root /usr/local/var/log/tinyproxy/tinyproxy.log
echo "ok"

username=$1
password=$2

echo "Adding conf file"
cp ./tinyproxy.conf.template ./tinyproxy.conf
echo "BasicAuth $username $password" >> ./tinyproxy.conf
mv ./tinyproxy.conf /usr/local/etc/tinyproxy/tinyproxy.conf
echo "ok"

echo "Creating service"
cp ./tinyproxy.service /etc/systemd/system/tinyproxy.service
systemctl daemon-reload
echo "ok"

echo "Starting service"
systemctl start tinyproxy
systemctl enable tinyproxy.service
echo "done"


