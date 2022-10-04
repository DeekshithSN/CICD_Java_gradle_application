pipeline{
    agent any 
    environment{
        VERSION = "${env.BUILD_ID}"
    }
    stages{
        stage("sonar quality check"){
            agent {
                any {
                    image 'openjdk:11'
                }
            }
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token') {
                            sh 'chmod +x gradlew'
                            sh './gradlew sonarqube'
                    }
                    timeout(time: 1, unit: 'HOURS') {
                      def qg = waitForQualityGate()
                      if (qg.status != 'OK') {
                           error "Pipeline aborted due to quality gate failure: ${qg.status}"
                      }
                    }
                }  
            }
        }
        stage("docker build & docker push"){
            steps{
                script{
                    withCredentials([string(credentialsId: 'docker_pass', variable: 'docker_password')]) {
    
                        sh '''
                        docker build -t 192.168.1.202:8083/sprintapp:${VERSION} .
                        docker login -u admin -p $docker_password 192.168.1.202:8083
                        docker push 192.168.1.202:8083/sprintapp:${VERSION}
                        docker rmi 192.168.1.202:8083/sprintapp:${VERSION}
                        '''
                    }
                }
            }
        }
    }
}
