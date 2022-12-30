pipeline {
    agent any
    stages {
       stage('Sonary quality check') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonar') {
                        sh 'chmod +x gradlew'
                        sh './gradlew sonarqube --stacktrace' /* it will push code to sonar qube for static quality check */
                    }
                    timeout(30) {
                        def qualityGate = waitForQualityGate()
                        if (qualityGate.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qualityGate.status}"
                        }
                    }
                }
            }
       
        }
    }
}