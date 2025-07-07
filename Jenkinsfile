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
                    """
                
                    bat 'echo ✅ Successfully authenticated.'

                    // Check for existing test runs
                    bat """
                        echo 🔍 Checking for existing Apex test executions...
                        sf apex test queue list > queue_output.txt
                        findstr /C:"Queued" queue_output.txt
                        if %ERRORLEVEL% EQU 0 (
                            echo ⚠️ Apex tests already in progress. Exiting to avoid ALREADY_IN_PROCESS error.
                            exit /b 1
                        )
                    """

                    bat 'echo 🚀 Running Apex Tests...'

                    // Run Apex tests synchronously
                    bat """
                        sf apex test run ^
                            --result-format human ^
                            --wait 10 ^
                            --test-level RunLocalTests ^
                            --synchronous
                    """

                    // Handle result
                    bat """
                        if ERRORLEVEL 1 (
                            echo ❌ Apex tests failed.
                            exit /b 1
                        ) else (
                            echo ✅ Apex tests completed successfully!
                        )
                    """
                }
            }
        }
    }
}






