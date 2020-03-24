#!/bin/sh

chown mosquitto:mosquitto -R /var/lib/mosquitto

/usr/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf
