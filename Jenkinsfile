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
        
                    // Authenticate via JWT
                    bat """
                        sf auth jwt grant ^
                            --client-id %CONSUMER_KEY% ^
                            --jwt-key-file "%JWT_KEY%" ^
                            --username %SF_USERNAME% ^
                            --instance-url https://test.salesforce.com ^
                            --set-default
                    """
        
                    bat 'echo ✅ Successfully authenticated.'
                    bat 'echo 🚀 Running Apex Tests...'
        
                    // Run Apex tests asynchronously and capture output
                    bat """
                        sf apex test run ^
                            --result-format json ^
                            --wait 0 ^
                            --test-level RunLocalTests > test_run.json
                    """
        
                    // Extract test run ID from the JSON
                    bat """
                        for /f "tokens=2 delims=:" %%A in ('findstr /C:"testRunId" test_run.json') do (
                            set TEST_RUN_ID=%%~A
                            set TEST_RUN_ID=!TEST_RUN_ID:,=!
                        )
                        echo Extracted test run ID: !TEST_RUN_ID!
                    """
        
                    // Retrieve test results
                    bat """
                        for /f "tokens=2 delims=:" %%A in ('findstr /C:"testRunId" test_run.json') do (
                            set TEST_RUN_ID=%%~A
                            set TEST_RUN_ID=!TEST_RUN_ID:,=!
                            call sf apex get test --test-run-id !TEST_RUN_ID! --result-format human
                            if ERRORLEVEL 1 (
                                echo ❌ Apex tests failed.
                                exit /b 1
                            ) else (
                                echo ✅ Apex tests completed successfully!
                            )
                        )
                    """
                }
            }
        }
    }
}






