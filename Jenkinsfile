def getDockerTag(){
        def tag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        return tag
}

def getAwsAccountID(){
        def accountid = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
        return accountid
}

pipeline{
    agent {
        label 'ec2-fleet'
    } 

    environment{
	    Docker_tag = getDockerTag()
        aws_account_id = getAwsAccountID()
        aws_region = "us-east-1"
    }
    
    stages{
        stage('Build and Sonar Parallel') {
            parallel {
                stage("build"){
                    steps{
                        script{
                            docker.image('openjdk:11').inside('--user root') {
                                sh 'chmod +x gradlew'
                                sh 'whoami'
                                sh './gradlew build'
                            }
                        }
                    }
                }

                stage("sonar scan"){
                    steps{
                        script{
                            docker.image('openjdk:11').inside('--user root') {
                            try {
                                withSonarQubeEnv(credentialsId: 'sonar-token') {
                                        sh 'chmod +x gradlew'
                                        sh './gradlew sonarqube'
                                }
                            } catch (err) {
                                currentBuild.result = 'UNSTABLE'
                                echo "SonarQube scan failed, marking build as UNSTABLE. Error: ${err}"
                                return // skip waitForQualityGate if gradle failed
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
            }
       }
    }
    stage("docker build"){
            steps{
                script{
                    sh 'docker build -t spring-app:${Docker_tag} . '
                    currentBuild.description = "spring-app:${Docker_tag}"
                }
            }
        }

    stage("docker push"){
            steps{
                script{
                    sh '''
                        aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com
                        docker tag spring-app:${Docker_tag} ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/spring-app:${Docker_tag}
                        docker push ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/spring-app:${Docker_tag}
                        docker rmi ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/spring-app:${Docker_tag} spring-app:${Docker_tag}
                    '''
                }
            }
        }

        stage("prepare helm charts"){
            steps{
                script{
                    sh '''
                        sed -i "s:IMAGE_NAME:${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/spring-app:" kubernetes/myapp/values.yaml
                        sed -i "s:IMAGE_TAG:${Docker_tag}:" kubernetes/myapp/values.yaml
                        helm package kubernetes/myapp/
                        aws s3 cp spring-app* s3://nimbus-python-practice/helm-charts
                    '''
                }
            }
        }

    }
    post {
		always {
            archiveArtifacts artifacts: 'build/reports/tests/test/**', followSymlinks: false
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'build/reports/tests/test/', reportFiles: 'index.html', reportName: 'test-case-report', reportTitles: 'test-case-report', useWrapperFileDirectly: true])
            cleanWs()
		 }
	   }
}