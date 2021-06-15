#!/usr/bin/env bash

pid_file="/home/ec2-user/Systumbdi/salesperson-web/shared/tmp/pids/puma.pid" # Cluster PID
pid_dir=$(dirname $pid_file)

sudo kill -9 $(cat $pid_dir/puma/worker_$1.pid)