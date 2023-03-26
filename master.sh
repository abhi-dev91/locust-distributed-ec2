#!/bin/bash

apt-get update
apt-get install python3-pip -y
pip3 install locust
ulimit -n 65535

cat >> /etc/security/limits.conf <<EOF
* soft nofile 65535
* hard nofile 65535
EOF


cat >> script.py <<EOF
import gevent
from locust.contrib.fasthttp import FastHttpUser
from locust import HttpUser, task
import resource


class MyUser(FastHttpUser):
  @task
  def t(self):
      def concurrent_request(url):
          self.client.get(url)

      pool = gevent.pool.Pool()
      urls = ["/"]
      for url in urls:
          pool.spawn(concurrent_request, url)
      pool.join()
EOF

locust -f script.py --master
