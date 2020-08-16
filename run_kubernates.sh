#!/bin/bash
sleep 30
nohup kubectl port-forward deployment/udacity-capstone --address 0.0.0.0 80:80 &