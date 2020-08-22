def checkDeployment
pipeline {
    environment { 
	        registry = "captainbelal/udacity_capstone" 
	        registryCredential = 'Docker'
            registryToken = credentials('token') 
	        dockerImage = ''
            key = credentials('key')
			kubernates = credentials('kubernates') 
	}
    agent any
    stages {
        stage('Linting HTML'){
            steps {
                sh 'echo "Linting HTML"'
                sh 'tidy -q -e *.html'
            }
        }
        stage('Linting DockerFile') { 
            steps { 
                sh 'hadolint Dockerfile' 
            }
        }
        stage('Build Docker Image') { 
            steps { 
                script{
                    dockerImage = docker.build registry+":$BUILD_NUMBER"
                }
            }
        }
        stage('Push Docker Image to Docker Hub'){
            steps{
                sh("docker login --username captainbelal -p $registryToken")
                sh "docker push $registry:$BUILD_NUMBER"
            }
        }
        stage('Clean UP Docker Image from machine'){
            steps { 
                sh "docker rmi $registry:$BUILD_NUMBER" 
            }
        }
        stage('CloudFormation Create or Update'){
            steps {
                withAWS(region:'us-west-2',credentials:'aws-static') {
                    sh 'echo "Create CF Stack"'
                    sh '''
                        echo "\nChecking if stack exists ..."
                        if ! aws cloudformation describe-stacks --stack-name udacity-capstone ; then
                            echo -e "\nStack does not exist, creating ..."
                            aws cloudformation create-stack --stack-name udacity-capstone --template-body file://project.yml  --parameters file://project-parameters.json
                            echo "\nWaiting for stack to be created ..."
                            aws cloudformation wait stack-create-complete --stack-name udacity-capstone
                        else
                            echo -e "\nStack exists, attempting update ..."                    
                            set +e
                            update_output=$( aws cloudformation update-stack --stack-name udacity-capstone --template-body file://project.yml  --parameters file://project-parameters.json  2>&1)
                            status=$?
                            set -e                        
                            if [ $status -ne 0 ] ; then
                                echo -e "\nFinished create/update - no updates to be performed"
                            else
                                echo "\nWaiting for stack update to complete ..."
                                aws cloudformation wait stack-update-complete --stack-name udacity-capstone
                            fi                            
                        fi
                    '''
                }
            }
        }
        stage('Get EC2 IP and Validate Deployment Exist '){
            steps {
                withAWS(region:'us-west-2',credentials:'aws-static') {
                    sh ''' 
                        EC2IP=$( aws ec2 describe-instances --filters "Name=tag-value,Values=KubernatesInstance" "Name=instance-state-name,Values=running" --query Reservations[*].Instances[*].[PublicIpAddress] --output text )
                        rm -f /tmp/ec2ip.txt
                        echo $EC2IP > /tmp/ec2ip.txt
                    '''
                }

                script{
                    sshagent (credentials: ['kubernates']) {
                        sh '''
                        sleep 30
                        EC2IP=$(cat /tmp/ec2ip.txt)
                        set +e 
                        checkDeployment=$(ssh -o StrictHostKeyChecking=no -l ubuntu $EC2IP kubectl get deployments udacity-capstone)
                        set -e
                        if [[ $checkDeployment -eq 0 ]]; then
                            checkDeployment = "False"
                        else
                            checkDeplyment = "True"
                        fi
                        rm -f /tmp/checkDeployment.txt
                        echo $checkDeployment > /tmp/checkDeployment.txt
                        '''
                  }
                }
            }
        }
        stage('Create Kubernates Deployment to EC2'){
            when {
                expression { checkDeployment == "False" }
            }
            steps{
                retry(count: 3) {
                    script{
                        sshagent (credentials: ['kubernates']) {
                            sh 'echo "Sleep 30 Seconds"'
                            sh 'sleep 30'
                            sh '''
                            EC2IP=$(cat /tmp/ec2ip.txt)
                            ssh -o StrictHostKeyChecking=no -l ubuntu $EC2IP minikube start
                            ssh -o StrictHostKeyChecking=no -l ubuntu $EC2IP minikube addons enable ingress
                            ssh -o StrictHostKeyChecking=no -l ubuntu $EC2IP sed -i "s/BUILD_NUMBER/$BUILD_NUMBER/g" udacity_Capstone/kube_deployments.yml
                            ssh -o StrictHostKeyChecking=no -l ubuntu $EC2IP sudo kubectl apply -f udacity_Capstone/kube_deployments.yml
                            ssh -o StrictHostKeyChecking=no -l ubuntu $EC2IP kubectl expose deployment udacity-capstone --type=NodePort --port=80
                            sleep 30
                            ssh -o StrictHostKeyChecking=no -l ubuntu $EC2IP sudo kubectl apply -f udacity_Capstone/minikube_Ingress.yml
                            ssh -o StrictHostKeyChecking=no -l ubuntu $EC2IP sudo sh udacity_Capstone/nginx.sh
                            '''
                        }                        
                    }
                }
            }
        }
        stage('Kubernates Rolling Out'){
            when {
                expression { checkDeployment != "False" }
            }
            steps{
                script{
                    sshagent (credentials: ['kubernates']) {
                        sh '''
                        EC2IP=$(cat /tmp/ec2ip.txt)
                        ssh -o StrictHostKeyChecking=no -l ubuntu $EC2IP kubectl set image deployment/udacity-capstone  udacity-capstone=$registry:$BUILD_NUMBER --record
                        '''
                    }                        
                }
            }
        }            
    }      
}