#!/bin/bash
sed -i "s/minikube_ip/$(minikube ip)/g" udacity_Capstone/reverse-proxy.conf
cp udacity_Capstone/reverse-proxy.conf /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
service nginx restart