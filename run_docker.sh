#!/bin/bash
export DockerBuildVersion=1
DockerTagNum="v ${DockerBuildVersion}"
docker build -t captainbelal/udacity_capstone:$DockerTagNum .
sudo cadocker push captainbelal/udacity_capstone:$DockerTagNum
export DockerBuildVersion=$(($DockerBuildVersion+1))