/*
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
                    // Replace backslashes with forward slashes for Docker on Windows
                    def workspacePath = env.WORKSPACE.replace('\\', '/')

                    // Explicitly run docker run with volume and working directory in Linux style
                    bat """
                    docker run --rm -v ${workspacePath}:/workspace -w /workspace salesforce-cli:latest sf --version
                    """
                }
            }
        }
    }
}
*/

pipeline {
    agent any

    environment {
        // Secret text credentials (configured in Jenkins)
        SF_USERNAME = credentials('sf-username')
        SF_CONSUMER_KEY = credentials('sf-consumer-key')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }

        stage('Authenticate to Salesforce') {
            steps {
                script {
                    def workspacePath = env.WORKSPACE.replace('\\', '/')
        
                    // Inject private key into workspace
                    withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'SF_JWT_KEY_PATH')]) {
        
                        // Copy the private key into workspace
                        bat """copy "%SF_JWT_KEY_PATH%" "${workspacePath}\\sf-jwt.key" """
        
                        // Run Docker with env vars passed inside the container instead of string interpolation
                        withEnv(["SF_JWT_KEY_FILE=sf-jwt.key"]) {
                            bat '''
                            docker run --rm -v %WORKSPACE%:/workspace -w /workspace salesforce-cli:latest ^
                                sf auth jwt:grant ^
                                --client-id %SF_CONSUMER_KEY% ^
                                --jwt-key-file %SF_JWT_KEY_FILE% ^
                                --username %SF_USERNAME% ^
                                --set-default ^
                                --instance-url https://login.salesforce.com
                            '''
                        }
                    }
                }
            }
        }


        stage('Verify Connection') {
            steps {
                script {
                    def workspacePath = env.WORKSPACE.replace('\\', '/')

                    // Run a simple command to verify connection
                    bat """
                    docker run --rm -v ${workspacePath}:/workspace -w /workspace salesforce-cli:latest sf org list
                    """
                }
            }
        }
    }
}

