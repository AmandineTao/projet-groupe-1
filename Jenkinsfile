pipeline{
     environment {
       IMAGE_NAME = "diranenodejs"
       IMAGE_TAG = "latest"
	   docker_user = "pintade"
       IMAGE_PORT = 8000
     }
    agent any
    stages {
        stage("build"){
			agent any
            steps {
                sh """
                    docker build -t ${docker_user}/${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }
    stage('Test') {
      steps {
        echo 'Testing...'
        snykSecurity(
          snykInstallation: 'Snyk',
          snykTokenId: 'snyk_token',
          severity: 'high',
        )
      }
    }
        stage("run"){
			agent any
            steps{
                sh """
                    docker run --name $IMAGE_NAME -d -p ${IMAGE_PORT}:8000 ${docker_user}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
		
	stage('Test image') {
           agent any
           steps {
              script {
                sh '''
                    sleep 10
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
                 docker stop $IMAGE_NAME
                 docker rm $IMAGE_NAME
               '''
             }
          }
     }
	 
	 stage('Push docker') {
        agent any
         steps {
           script {
            withCredentials([string(credentialsId: 'docker_pw', variable: 'SECRET')]) {
              sh '''
                docker login -u ${docker_user} -p ${SECRET}
                docker image push ${docker_user}/${IMAGE_NAME}:${IMAGE_TAG}
              '''
            }
			}
        }
     }

  stage('install galaxy') {
        agent any
        steps {
            script {
              sh '''
                ansible-galaxy collection install -r ./ansible/collections/requirements.yml
              '''
            }
        }
    }

  stage('Ansible') {
    agent any
    steps {
      ansiColor('xterm') {
        ansiblePlaybook( 
            playbook: 'ansible/deploy.yml',
            inventory: 'ansible/hosts.yml',
            colorized: true) 
      }
    }
  }
	 
    }
	  

	
	
}