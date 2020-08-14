DockerTagNum="v $DockerBuildVersion"
docker build -t captainbelal/udacity_capstone:$DockerTagNum .
docker push captainbelal/udacity_capstone:$DockerTagNum
export DockerBuildVersion=$(($DockerBuildVersion+1))