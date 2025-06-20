pipeline {
    agent any
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }
        
        stage('Run Salesforce CLI') {
            steps {
                script {
                    // Fix Windows path for Docker volume mount by replacing backslashes with slashes
                    def workspacePath = env.WORKSPACE.replace('\\', '/')
                    docker.image('salesforce-cli:latest').inside("-v ${workspacePath}:/workspace -w /workspace") {
                        sh 'sf --version'
                        // Add your SF CLI commands here
                    }
                }
            }
        }
    }
}
