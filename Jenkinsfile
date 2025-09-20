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
        label 'aws-ec2'
    }

    environment{
	    Docker_tag = getDockerTag()
        aws_region = 'ap-south-1'
        aws_account_id = getAwsAccountID()
    }

    stages{
        stage('intial checks'){
             parallel { 
                stage('tool check'){
                    steps{
                        script{
                             sh 'chmod +x health-check.sh'
                            sh './health-check.sh'
                            currentBuild.description = "Branch: ${env.GIT_BRANCH}"
                        }  
                    }
                }

                stage('lint'){
                    steps{
                        script{

                            def app = docker.build("lint", "-f Dockerfile-lint .")

                            app.inside('--user root') {
                                try { 
                                        sh 'chmod +x lint-all.sh'
                                        sh './lint-all.sh'
                                    } 
                                    catch (err) {
                                        currentBuild.result = 'UNSTABLE'
                                        echo "Please correct linter issues "
                                        return // skip waitForQualityGate if gradle failed
                                    }
                            }
                        }  
                    }
                }
            }
        }

    stage('parallel execution'){ 
         parallel {
        stage('Static Code Analysis'){
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

        stage('build'){
            steps{
                script{
                    docker.image('openjdk:11').inside('--user root') {
                        sh 'chmod +x gradlew'
                        sh './gradlew build'
                    }
                }  
            }

        }
         }
    }
        stage('docker build & publish image'){
            steps{
                script{
                    sh '''
                        echo "[default]" > /home/ubuntu/.aws/config
                        echo "region = ap-south-1" >> /home/ubuntu/.aws/config
                        export AWS_CONFIG_FILE="/home/ubuntu/.aws/config"
                        docker build -t spring-app:${Docker_tag} .
                        aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com
                        docker tag spring-app:${Docker_tag} ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/spring-app:${Docker_tag}
                        docker push ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/spring-app:${Docker_tag}
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
                        helmversion=$( helm show chart kubernetes/myapp/ | grep version | cut -d: -f 2 | tr -d ' ')
                        aws s3 cp myapp-$helmversion.tgz s3://nimbuswiztech-website/helm-charts/spring-app-$helmversion.tgz
                    '''
                }
            }
        }


        stage("deploy to eks cluster"){
            steps{
                script{
                     withCredentials([usernamePassword(credentialsId: 'aws-login-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {

                    sh '''
                        echo "[default]" > /home/ubuntu/.aws/config
                        echo "region = ap-south-1" >> /home/ubuntu/.aws/config
                        export AWS_CONFIG_FILE="/home/ubuntu/.aws/config"
                        aws eks update-kubeconfig --region ${aws_region} --name my-eks-cluster
                        helm upgrade --install myjavaapp kubernetes/myapp/
                        helm list 
                        sleep 120
                        kubectl get po 
                        
                    '''
                    }
                }
            }
        }

        stage("Verify deployment"){
            steps{
                script{
                     withCredentials([usernamePassword(credentialsId: 'aws-login-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {

                    sh '''
                        echo "[default]" > /home/ubuntu/.aws/config
                        echo "region = ap-south-1" >> /home/ubuntu/.aws/config
                        export AWS_CONFIG_FILE="/home/ubuntu/.aws/config"
                        aws eks update-kubeconfig --region ${aws_region} --name my-eks-cluster
                        kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl myjavaapp-myapp:8080
                        
                    '''
                    }
                }
            }

            post {
                always {
                  withCredentials([usernamePassword(credentialsId: 'aws-login-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {

                    sh '''
                        echo "[default]" > /home/ubuntu/.aws/config
                        echo "region = ap-south-1" >> /home/ubuntu/.aws/config
                        export AWS_CONFIG_FILE="/home/ubuntu/.aws/config"
                        aws eks update-kubeconfig --region ${aws_region} --name my-eks-cluster
                        helm uninstall myjavaapp
                        
                    '''
                    }
                }
            }
        }

    }

    post {
		always {
            archiveArtifacts artifacts: 'kubernetes/myapp/', followSymlinks: false
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'build/reports/tests/test/', reportFiles: 'index.html', reportName: 'test-case-report', reportTitles: 'test-case-report', useWrapperFileDirectly: true])
            cleanWs()
		 }
	   }
}