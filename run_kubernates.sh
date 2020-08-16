#!/bin/bash
minikube start --vm-driver=none
kubectl create deployment udacity-capstone --image=captainbelal/udacity_capstone:86
sleep 30
kubectl port-forward deployment/udacity-capstone --address 0.0.0.0 80:80 &