DockerTagNum="v $DockerBuildVersion"
docker build -t captainbelal/udacity_capstone:$DockerTagNum .
sudo docker push captainbelal/udacity_capstone:$DockerTagNum
export DockerBuildVersion=$(($DockerBuildVersion+1))