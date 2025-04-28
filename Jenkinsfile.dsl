pipelineJob('sample-app') {
    description('pipeline runs ci for gradle app')
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/DeekshithSN/CICD_Java_gradle_application.git')
                        
                    }
                    branch('*/demo_app')  // or '*/master' or any branch
                }
            }
            scriptPath('Jenkinsfile') // Path to the Jenkinsfile inside the repo
        }
    }
}
