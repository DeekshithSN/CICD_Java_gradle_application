pipeline{
    agent any 
    environment{
        VERSION = "${env.BUILD_ID}"
    }
    stages{
        // stage("sonar quality check"){
        //     agent {
        //         docker {
        //             image 'openjdk:11'
        //         }
        //     }
        //     steps{
        //         script{
        //             withSonarQubeEnv(credentialsId: 'sonarqube') {
        //                     sh 'chmod +x gradlew'
        //                     sh './gradlew -Dsonar.host.url=http://54.91.142.27:9000 sonarqube --warning-mode all'
        //             }
        //            timeout(time: 1, unit: 'HOURS') {
        //               def qg = waitForQualityGate()
        //               if (qg.status != 'OK') {
        //                    error "Pipeline aborted due to quality gate failure: ${qg.status}"
        //               }
        //             }
        //        }  
        //     }
        // }
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

        // stage('manual approval'){
        //     steps{
        //         script{
        //             timeout(10) {
        //                 mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> Go to build url and approve the deployment request <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "deekshith.snsep@gmail.com";  
        //                 input(id: "Deploy Gate", message: "Deploy ${params.project_name}?", ok: 'Deploy')
        //             }
        //         }
        //     }
        // }

        stage('Deploying application on k8s cluster') {
            steps {
               script{
                        dir('kubernetes/') {
                          sh 'helm upgrade --install --set image.repository="54.91.142.27:8083/test-app" --set image.tag="${VERSION}" myjavaapp myapp/ ' 
                        }
                    
               }
            }
        }
        

        // stage('verifying app deployment'){
        //     steps{
        //         script{
        //              withCredentials([kubeconfigFile(credentialsId: 'kubernetes-config', variable: 'KUBECONFIG')]) {
        //                  sh 'kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl myjavaapp-myapp:8080'

        //              }
        //         }
        //     }
        // }
    }

    
}
