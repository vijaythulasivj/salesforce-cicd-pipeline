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
/*
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
        
                    withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'SF_JWT_KEY_PATH')]) {
        
                        // Copy private key into workspace
                        bat """copy "%SF_JWT_KEY_PATH%" "${workspacePath}\\sf-jwt.key" """
        
                        // Run Docker with environment variables and call sf directly
                        bat """
                        docker run --rm ^
                            -v "${workspacePath}:/workspace" ^
                            -w /workspace ^
                            -e SF_USERNAME=%SF_USERNAME% ^
                            -e SF_CONSUMER_KEY=%SF_CONSUMER_KEY% ^
                            -e SF_JWT_KEY_FILE=sf-jwt.key ^
                            salesforce-cli:latest ^
                            sf auth jwt:grant --client-id %SF_CONSUMER_KEY% --jwt-key-file sf-jwt.key --username %SF_USERNAME% --set-default --instance-url https://login.salesforce.com
                        """
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
                    docker run --rm ^
                        -v "${workspacePath}:/workspace" ^
                        -w /workspace ^
                        salesforce-cli:latest ^
                        sf org list
                    """
                }
            }
        }
    }
}
*/

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

        stages {
            stage('Authenticate Salesforce') {
                steps {
                    withCredentials([
                        string(credentialsId: 'sf-username', variable: 'SF_USERNAME'),
                        string(credentialsId: 'sf-consumer-key', variable: 'SF_CONSUMER_KEY'),
                        file(credentialsId: 'sf-jwt-private-key', variable: 'SF_JWT_KEY_PATH')
                    ]) {
                        // Debug: Check variables (masked in console)
                        bat '''
                        echo SF_USERNAME=%SF_USERNAME%
                        echo SF_CONSUMER_KEY=%SF_CONSUMER_KEY%
                        dir "%SF_JWT_KEY_PATH%"
                        '''
    
                        // Copy JWT key file to workspace as sf-jwt.key
                        bat 'copy "%SF_JWT_KEY_PATH%" "%WORKSPACE%\\sf-jwt.key"'
    
                        // Run Salesforce CLI in Docker, mounting workspace
                        bat '''
                        docker run --rm ^
                          -v "%WORKSPACE%:/workspace" ^
                          -w /workspace ^
                          -e SF_USERNAME=%SF_USERNAME% ^
                          -e SF_CONSUMER_KEY=%SF_CONSUMER_KEY% ^
                          -e SF_JWT_KEY_FILE=sf-jwt.key ^
                          salesforce-cli:latest ^
                          sf auth jwt:grant --client-id %SF_CONSUMER_KEY% --jwt-key-file sf-jwt.key --username %SF_USERNAME% --set-default --instance-url https://login.salesforce.com
                        '''
    
                        // Optional: List authenticated orgs
                        bat '''
                        docker run --rm ^
                          -v "%WORKSPACE%:/workspace" ^
                          -w /workspace ^
                          salesforce-cli:latest ^
                          sf org list --all
                        '''
                    }
                }
            }
        }
    }
}


