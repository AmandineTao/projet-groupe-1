pipeline{
    
     environment{
        IMAGE_NAME = "${BUILD_NAME}"
        IMAGE_TAG = "${BUILD_TAG}"
        CONTAINER_NAME = "${CONTAINER_NAME}"
        USERNAME = "${USERNAME}"
       

    }

    agent any

    stages{
        stage ('Build Image'){
            agent any
            steps{
                script{
                    sh 'docker build -t ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} .'
                }
            }
        }


        stage ('Run container based on Builded image'){
            agent any
            steps{
                script{
                    sh '''
                        docker run --name ${CONTAINER_NAME} -d -p ${IMAGE_PORT}:8000 ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        sleep 5
                    ''' 
                }
            }
        }

    stage('Test') {
      steps {
        echo 'Testing...'
        snykSecurity(
          snykInstallation: 'snyk',
          snykTokenId: 'snyk_token',
          severity: 'high',
        )
      }
    }

        stage ('Test Image'){
            agent any
            steps{
                script{
                    sh '''
                       #curl http://172.17.0.1 | grep -q "Présentation"
                       curl -sL -w '%{http_code}\n' http://172.17.0.1:${IMAGE_PORT} -o /dev/null | grep -q 200
                    '''
                }
            }
        }

        stage('Clean Container') {
            agent any
            steps {
                script {
                    sh '''
                       docker stop ${CONTAINER_NAME}
                       docker rm ${CONTAINER_NAME}
                    '''
                }
            }
        }

       stage('Push image to Dockerhub') {
            agent any
            steps {
                script {
                    sh '''
                       docker login -u ${USERNAME} -p ${PASSWORD}
                       docker push ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }
    }
}