#!/bin/bash

killall wsd_simple_server
sleep 2
killall wsd_simple_server
sleep 2

while [ 1 ];
do
        wsd_simple_server -f  -i eth0 -x http://%s/onvif/device_service -p /var/run/wsd_simple_server.pid -n EPCB -m EPCAM-01
        sleep 10
done

exit 0