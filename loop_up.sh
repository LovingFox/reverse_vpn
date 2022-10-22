#!/bin/bash

set -e

sudo ip link add wgloop type dummy
sudo ip link set wgloop up
