pipeline{
    agent any 
    environment{
        VERSION = "${env.BUILD_ID}"
    }
    stages{
        stage("sonar quality check"){
            agent {
                docker {
                    image 'adoptopenjdk/openjdk11'
                }
            }
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonarqube') {
                            sh 'chmod +x gradlew'
                            sh './gradlew -Dsonar.host.url=http://54.91.142.27:9000 sonarqube --warning-mode all'
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
                    withCredentials([string(credentialsId: 'docker-pass', variable: 'docker_password')]) {
                             sh '''
                                docker build -t 54.91.142.27:8083/test-app:${VERSION} .
                                docker login -u admin -p $docker_password 54.91.142.27:8083 
                                docker push  54.91.142.27:8083/test-app:${VERSION}
                                docker rmi 54.91.142.27:8083/test-app:${VERSION}
                            '''
                    }
                }
            }
        }
        stage('indentifying misconfigs using datree in helm charts'){
            steps{
                script{
                  dir('kubernetes/') {
                        withEnv(['DATREE_TOKEN=06736911-56d1-416f-aaa2-4c872f7f821f']) {
                              sh '''
                                 helm datree test myapp/
                            '''
                        }
                    }
                }
            }
        }
        stage("pushing the helm charts to nexus"){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'nexus', passwordVariable: 'nexus_password', usernameVariable: 'nexus_username')]) {
                              dir('kubernetes/') {
                             sh '''
                                 helmversion=$( helm show chart myapp | grep version | cut -d: -f 2 | tr -d ' ')
                                 tar -czvf  myapp-${helmversion}.tgz myapp/
                                 curl -u $nexus_username:$nexus_password http://54.91.142.27:8081/repository/helm-hosted/ --upload-file myapp-${helmversion}.tgz -v
                            '''
                          }
                    }
                }
            }
        }

        

        stage('Deploying application on k8s cluster') {
            steps {
               script{
                        dir('kubernetes/') {
                          sh 'helm upgrade --install --set image.repository="54.91.142.27:8083/test-app" --set image.tag="${VERSION}" myjavaapp myapp/ ' 
                        }
                    
               }
            }
        }
        

        
    }

    
}
