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
        CONSUMER_KEY = credentials('sf-consumer-key')       // Consumer Key from Connected App
        SF_USERNAME = credentials('sf-username')            // Sandbox user (e.g., user@domain.sandbox)
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }
        /*
        stage('Test JWT Connection to Salesforce') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                        echo ==================================================
                        echo Starting Salesforce JWT Authentication Test
                        echo ==================================================

                        echo Jenkins user: %USERNAME%
                        echo PATH: %PATH%

                        echo Checking Salesforce CLI...
                        where sf || (
                            echo ERROR: Salesforce CLI not found. Exiting...
                            exit /b 1
                        )

                        echo Authenticating to Salesforce Sandbox via JWT...
                        sf auth jwt grant ^
                            --client-id %CONSUMER_KEY% ^
                            --jwt-key-file "%JWT_KEY%" ^
                            --username %SF_USERNAME% ^
                            --instance-url https://test.salesforce.com ^
                            --set-default

                        if ERRORLEVEL 1 (
                            echo ERROR: JWT authentication failed.
                            exit /b 1
                        )

                        echo ✅ Successfully authenticated to Salesforce!

                        echo Displaying Org Info...
                        sf org display
                    """
                }
            }
        }
        */
        stage('Run Apex Tests') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                        sf auth jwt grant ^
                            --client-id %CONSUMER_KEY% ^
                            --jwt-key-file "%JWT_KEY%" ^
                            --username %SF_USERNAME% ^
                            --instance-url https://test.salesforce.com ^
                            --set-default
        
                        echo Running Apex tests...
        
                        sf apex test run --result-format human --wait 10 --test-level RunLocalTests
        
                        if ERRORLEVEL 1 (
                            echo ❌ Apex tests failed.
                            exit /b 1
                        )
        
                        echo ✅ Apex tests completed successfully!
                    """
                }
            }
        }
    }
}






