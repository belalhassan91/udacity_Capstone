#!/bin/bash
minikube start
kubectl create deployment udacity-capstone --image=captainbelal/udacity_capstone:86
kubectl port-forward deployment/udacity-capstone --address 0.0.0.0 80:80