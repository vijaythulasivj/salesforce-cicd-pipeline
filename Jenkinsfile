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
*/
pipeline {
    agent any
    
    environment {
        CONSUMER_KEY = credentials('sf-consumer-key')
        SF_USERNAME = credentials('sf-username')
        DOCKER_IMAGE = 'salesforce-cli:latest'
    }
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        docker.build(env.DOCKER_IMAGE)
                        echo "✅ Docker image built successfully"
                    } catch (Exception e) {
                        echo "❌ Docker build failed: ${e.getMessage()}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }
        
        stage('Authenticate to Salesforce') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        try {
                            bat """
                                sf auth jwt grant ^
                                    --client-id %CONSUMER_KEY% ^
                                    --jwt-key-file "%JWT_KEY%" ^
                                    --username %SF_USERNAME% ^
                                    --instance-url https://test.salesforce.com ^
                                    --set-default
                            """
                            echo "✅ Successfully authenticated to Salesforce"
                        } catch (Exception e) {
                            echo "❌ Authentication failed: ${e.getMessage()}"
                            currentBuild.result = 'FAILURE'
                            throw e
                        }
                    }
                }
            }
        }
        
        stage('Check for Running Tests') {
            steps {
                script {
                    try {
                        // Check if there are any running test runs
                        def result = bat(
                            script: """
                                sf data query ^
                                    --query "SELECT Id, Status FROM ApexTestRunResult WHERE Status IN ('Queued', 'Processing') LIMIT 1" ^
                                    --result-format json > running_tests.json 2>&1
                                type running_tests.json
                            """,
                            returnStatus: true
                        )
                        
                        if (result == 0) {
                            // Check if there are running tests
                            def runningTestsCheck = bat(
                                script: 'findstr /C:"totalSize" running_tests.json | findstr /C:":0"',
                                returnStatus: true
                            )
                            
                            if (runningTestsCheck != 0) {
                                echo "⚠️  Found running tests. Waiting for completion..."
                                // Wait for running tests to complete
                                timeout(time: 10, unit: 'MINUTES') {
                                    waitUntil {
                                        script {
                                            def checkResult = bat(
                                                script: """
                                                    sf data query ^
                                                        --query "SELECT Id, Status FROM ApexTestRunResult WHERE Status IN ('Queued', 'Processing') LIMIT 1" ^
                                                        --result-format json > check_tests.json 2>&1
                                                    findstr /C:"totalSize" check_tests.json | findstr /C:":0"
                                                """,
                                                returnStatus: true
                                            )
                                            return checkResult == 0
                                        }
                                    }
                                }
                                echo "✅ Previous tests completed. Proceeding..."
                            }
                        }
                    } catch (Exception e) {
                        echo "⚠️  Could not check running tests, proceeding anyway: ${e.getMessage()}"
                    }
                }
            }
        }
        
        stage('Run Apex Tests') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        try {
                            echo "🚀 Starting Apex Tests..."
                            
                            // Run tests with retry logic
                            retry(3) {
                                def testResult = bat(
                                    script: """
                                        sf apex test run ^
                                            --result-format json ^
                                            --wait 10 ^
                                            --test-level RunLocalTests > test_results.json 2>&1
                                        type test_results.json
                                    """,
                                    returnStatus: true
                                )
                                
                                if (testResult != 0) {
                                    // Check if it's the "already in process" error
                                    def alreadyRunning = bat(
                                        script: 'findstr /C:"ALREADY_IN_PROCESS" test_results.json',
                                        returnStatus: true
                                    )
                                    
                                    if (alreadyRunning == 0) {
                                        echo "⚠️  Tests already running, waiting 30 seconds before retry..."
                                        sleep(30)
                                        error("Tests already in process, retrying...")
                                    } else {
                                        error("Test execution failed with exit code: ${testResult}")
                                    }
                                }
                            }
                            
                            // Parse and display results
                            echo "📊 Parsing test results..."
                            bat """
                                echo.
                                echo ===== TEST RESULTS SUMMARY =====
                                findstr /C:"outcome" test_results.json
                                findstr /C:"testsRan" test_results.json
                                findstr /C:"passing" test_results.json
                                findstr /C:"failing" test_results.json
                                findstr /C:"coverage" test_results.json
                                echo =================================
                            """
                            
                            // Check if tests passed
                            def testsPassed = bat(
                                script: 'findstr /C:"Passed" test_results.json',
                                returnStatus: true
                            )
                            
                            if (testsPassed == 0) {
                                echo "✅ All Apex tests passed successfully!"
                            } else {
                                echo "❌ Some Apex tests failed. Check the detailed results above."
                                currentBuild.result = 'FAILURE'
                                error("Apex tests failed")
                            }
                            
                        } catch (Exception e) {
                            echo "❌ Test execution failed: ${e.getMessage()}"
                            currentBuild.result = 'FAILURE'
                            throw e
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Archive test results
                try {
                    archiveArtifacts artifacts: '*.json', allowEmptyArchive: true
                    echo "📁 Test results archived"
                } catch (Exception e) {
                    echo "⚠️  Could not archive artifacts: ${e.getMessage()}"
                }
                
                // Cleanup
                try {
                    bat 'if exist test_*.json del test_*.json'
                    bat 'if exist running_tests.json del running_tests.json'
                    bat 'if exist check_tests.json del check_tests.json'
                } catch (Exception e) {
                    echo "⚠️  Cleanup warning: ${e.getMessage()}"
                }
            }
        }
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "💥 Pipeline failed. Check the logs above for details."
        }
    }
}






