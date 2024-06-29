#!/bin/bash

sudo killall wsd_simple_server
sleep 2
sudo killall wsd_simple_server
sleep 2
sudo killall wsd_simple_server
sleep 2

sudo wsd_simple_server  -i ens32 -x http://%s:8080/onvif/device_service -p /var/run/wsd_simple_server.pid -d 5