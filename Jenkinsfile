def getDockerTag(){
        def tag = sh script: 'git rev-parse --short HEAD', returnStdout: true
        return tag
}

pipeline{
    agent {
        label 'ec2-fleet'
    } 

    environment{
	    Docker_tag = getDockerTag()
    }
    
    stages{
        stage("build"){
            steps{
                script{
                    docker.image('openjdk:11').inside {
                        sh 'chmod +x gradlew'
                        sh './gradlew build'
                    }
                }
            }
        }

        stage("sonar scan"){
            steps{
                script{
                    docker.image('openjdk:11').inside {
                     try {
                        withSonarQubeEnv(credentialsId: 'sonar-token') {
                                sh 'chmod +x gradlew'
                                sh './gradlew sonarqube --debug'
                        }
                     } catch (err) {
                        currentBuild.result = 'UNSTABLE'
                        echo "SonarQube scan failed, marking build as UNSTABLE. Error: ${err}"
                        return // skip waitForQualityGate if gradle failed
                    }

                    // timeout(time: 1, unit: 'HOURS') {
                    //   def qg = waitForQualityGate()
                    //   if (qg.status != 'OK') {
                    //        error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    //   }
                    // }
                }  
            }
        }
    }
    stage("docker build"){
            steps{
                script{
                    sh 'docker build -t sample-app:${Docker_tag} . '
                }
            }
        }

    stage("docker push"){
            steps{
                script{
                    sh 'docker images'
                    sh 'docker rmi $(docker images -qa)'
                }
            }
        }

    }
}