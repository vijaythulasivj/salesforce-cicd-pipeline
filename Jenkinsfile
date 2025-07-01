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
        CONSUMER_KEY = credentials('sf-consumer-key')
        SF_USERNAME = credentials('sf-username')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }

        stage('Test JWT Connection to Salesforce') {
          steps {
            withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
              sh '''
                echo "🔐 Testing JWT-based authentication to Salesforce..."
    
                sfdx auth:jwt:grant \
                  --clientid $CONSUMER_KEY \
                  --jwtkeyfile $JWT_KEY \
                  --username $SF_USERNAME \
                  --instanceurl https://login.salesforce.com \
                  --setalias jwt-test-user \
                  --setdefaultusername
    
                echo "✅ Successfully connected to Salesforce via JWT!"
                sfdx force:org:display
              '''
            }
          }
        }
    }
}




