/*
pipeline {
    agent any

    environment {
        CONSUMER_KEY = credentials('sf-consumer-key')
        SF_USERNAME = credentials('sf-username')
    }

    parameters {
        booleanParam(name: 'REDEPLOY_METADATA', defaultValue: false, description: 'Redeploy previously backed-up metadata?')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }

        stage('Authenticate Salesforce') { 
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                      "C:\\Program Files\\sf\\bin\\sf.cmd" auth jwt grant ^
                        --client-id %CONSUMER_KEY% ^
                        --jwt-key-file "%JWT_KEY%" ^
                        --username %SF_USERNAME% ^
                        --instance-url https://test.salesforce.com ^
                        --alias myAlias ^
                        --set-default ^
                        --no-prompt
                    """

                    bat 'echo ✅ Authenticated successfully.'
                }
            }
        }

        stage('🔍 Step 0: Validate CLI Execution') {
            when { expression { !params.REDEPLOY_METADATA } }
            steps {
                script {
                    // Define sfCmd variable here
                    def sfCmd = '"C:\\Program Files\\sf\\bin\\sf.cmd"'
                    echo 'Current working directory:'
                    bat 'cd'
                    echo '🔧 Checking that sf CLI runs and prints version...'
                    // Use sfCmd variable explicitly
                    def sfPath = bat(script: 'where sf', returnStdout: true).trim()
                    echo "🔍 sf executable path(s):\n${sfPath}"
                    def versionOutput = bat(script: "${sfCmd} --version", returnStdout: true).trim()
                    echo "📦 sf CLI version output:\n${versionOutput}"
        
                    echo '🔧 Checking deploy command prints something:'
        
                    def dryRunOutput = bat(
                        script: """
                            @echo off
                            echo >> Starting validation dry-run...
                            ${sfCmd} deploy metadata validate ^
                              --source-dir force-app/main/default/classes ^
                              --target-org myAlias ^
                              --test-level RunSpecifiedTests ^
                              --tests ASKYTightestMatchServiceImplTest ^
                              --json
                    
                            echo >> End of dry-run CLI output
                        """,
                        returnStdout: true
                    ).trim()
        
                    echo "🖨️ Raw deploy output:\n${dryRunOutput}"
                }
            }
        }

    
        stage('🔍 Step 0: Validate Deletion Readiness') {
            when {
                expression { return !params.REDEPLOY_METADATA }
            }
            steps {
                script {
                    echo '🧪 Validating potential impact of deletion using check-only deploy...'
        
                    withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                        def deployDir = 'destructive' // Folder containing package.xml and destructiveChanges.xml
                               
                        def output = bat(
                            script: """
                                @echo on
                                
                                echo ">> Starting dry-run deploy from ${deployDir}..."
                                sf project deploy start ^
                                    --manifest destructive/package.xml ^
                                    --target-org ciOrg ^
                                    --validation ^
                                    --test-level NoTestRun ^
                                    --json > validate_deletion_log.json
                                echo Deploy command exited with errorlevel: %ERRORLEVEL%
                                if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
                        
                                echo ">> ✅ Exited Deletion Validation Stage from GitHub Jenkinsfile"
                            """,
                            returnStdout: true
                        ).trim()
        
                        echo "🔍 Deploy command output:\n${output}"
                    }
                }
            }
        }
        
        stage('🔐 Step 1: Retrieve Metadata (Backup)') {
            when {
                expression { return !params.REDEPLOY_METADATA }
            }
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        echo '📦 Backing up metadata before deletion...'

                        bat 'if exist retrieved-metadata (rmdir /s /q retrieved-metadata)'
                        bat 'mkdir retrieved-metadata'

                        bat """
                            sf project retrieve start ^
                                --target-org %SF_USERNAME% ^
                               // --manifest manifest\\package.xml ^
                                --destructive destructive\\destructiveChanges.xml ^
                                --output-dir retrieved-metadata
                        """

                        bat 'powershell Compress-Archive -Path retrieved-metadata\\* -DestinationPath retrieved-metadata.zip -Force'
                    }
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'retrieved-metadata.zip', fingerprint: true
                }
            }
        }

        stage('🗑️ Step 2: Delete Metadata (Destructive Deployment)') {
            when {
                expression { return !params.REDEPLOY_METADATA }
            }
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        echo '🚨 Deleting metadata using destructiveChanges.xml...'
        
                        bat """
                            sf project deploy start ^
                                --target-org %SF_USERNAME% ^
                                --manifest destructive\\package.xml ^
                                --post-destructive-changes destructive\\destructiveChanges.xml ^
                                --ignore-warnings ^
                                --wait 10
                        """
                    }
                }
            }
        }
        
        stage('📦 Step 4: Redeploy from Backup (Optional Manual Trigger)') {
            when {
                expression { return params.REDEPLOY_METADATA }
            }
            steps {
                echo "📤 Redeploying previously retrieved metadata…"
        
                // Use last successful build to copy artifacts
                copyArtifacts(
                    projectName: env.JOB_NAME,
                    filter: 'retrieved-metadata.zip',
                    selector: lastSuccessful()
                )
        
                // Check if artifact exists
                script {
                    if (!fileExists('retrieved-metadata.zip')) {
                        error "❌ Could not retrieve 'retrieved-metadata.zip'. Redeploy cancelled."
                    }
                }
        
                // Expand and deploy
                bat 'powershell Expand-Archive -Path retrieved-metadata.zip -DestinationPath retrieved-metadata -Force'
        
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                        sf project deploy start ^
                            --target-org %SF_USERNAME% ^
                            --source-dir retrieved-metadata ^
                            --ignore-warnings ^
                            --wait 10
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
        CONSUMER_KEY = credentials('sf-consumer-key')
        SF_USERNAME = credentials('sf-username')
        SF_CMD = '"C:\\Program Files\\sf\\bin\\sf.cmd"' // ✅ Define once here
    }

    parameters {
        booleanParam(name: 'REDEPLOY_METADATA', defaultValue: false, description: 'Redeploy previously backed-up metadata?')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }

        stage('Authenticate Salesforce') { 
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                      %SF_CMD% auth jwt grant ^
                        --client-id %CONSUMER_KEY% ^
                        --jwt-key-file "%JWT_KEY%" ^
                        --username %SF_USERNAME% ^
                        --instance-url https://test.salesforce.com ^
                        --alias myAlias ^
                        --set-default ^
                        --no-prompt
                    """

                    bat 'echo ✅ Authenticated successfully.'
                }
            }
        }
        
        stage('🔍 Step 0: Validate CLI Execution') {
            when { expression { !params.REDEPLOY_METADATA } }
            steps {
                script {
                    echo '📁 Current working directory:'
                    bat 'cd'
        
                    echo '🔧 Validating sf CLI and running dry-run deployment...'
        
                    // Save CLI JSON output to a file
                    bat """
                        @echo off
                        echo Running validation with JSON output...
                        %SF_CMD% deploy metadata validate ^
                            --source-dir force-app/main/default/classes ^
                            --target-org myAlias ^
                            --test-level RunSpecifiedTests ^
                            --tests ASKYTightestMatchServiceImplTest ^
                            --json > deploy-result.json
                    """
        
                    echo '🐍 Generating CSV report from deploy-result.json...'
        
                    // ✅ Run the Python script using the full path
                    bat '"C:\\Users\\tsi082\\AppData\\Local\\Programs\\Python\\Python313\\python.exe" scripts\\generate_validation_report.py'
        
                    // ✅ Archive the CSV files so they are viewable/downloadable in Jenkins
                    archiveArtifacts artifacts: '*.csv', allowEmptyArchive: true
        
                    echo '✅ CSV report generated and archived.'
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
        SF_CMD = '"C:\\Program Files\\sf\\bin\\sf.cmd"' // ✅ Define once here
    }

    parameters {
        booleanParam(name: 'REDEPLOY_METADATA', defaultValue: false, description: 'Redeploy previously backed-up metadata?')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }

        stage('Authenticate Salesforce') { 
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                      %SF_CMD% auth jwt grant ^
                        --client-id %CONSUMER_KEY% ^
                        --jwt-key-file "%JWT_KEY%" ^
                        --username %SF_USERNAME% ^
                        --instance-url https://test.salesforce.com ^
                        --alias myAlias ^
                        --set-default ^
                        --no-prompt
                    """

                    bat 'echo ✅ Authenticated successfully.'
                }
            }
        }
        stage('🔍 Step 0: Validate and Report') {
            when { expression { !params.REDEPLOY_METADATA } }
            steps {
                script {
                    echo '📁 Checking working directory:'
                    bat 'cd'
        
                    echo '🔧 Step 1: Validating deployment metadata...'
                    bat """
                        @echo off
                        %SF_CMD% deploy metadata validate ^
                            --source-dir force-app/main/default/classes ^
                            --target-org myAlias ^
                            --test-level RunSpecifiedTests ^
                            --tests ASKYTightestMatchServiceImplTest ^
                            --json > deploy-result.json
                    """
        
                    echo '🧪 Step 2: Running tests for accurate code coverage...'
                    bat """
                        @echo off
                        %SF_CMD% apex run test ^
                            --tests ASKYTightestMatchServiceImplTest ^
                            --target-org myAlias ^
                            --code-coverage ^
                            --test-level RunSpecifiedTests ^
                            --json > test-result.json
                    """
        
                    echo '🧩 Step 3: Merging deploy and test results...'
                    bat '''@echo off
                    type deploy-result.json > combined-result.json
                    powershell -Command "$deploy = Get-Content deploy-result.json | ConvertFrom-Json; $test = Get-Content test-result.json | ConvertFrom-Json; $deploy.testRunResult = $test.result; $deploy | ConvertTo-Json -Depth 10 | Set-Content combined-result.json"
                    '''
        
                    echo '📊 Step 4: Generating Excel report...'
                    bat '"C:\\Users\\tsi082\\AppData\\Local\\Programs\\Python\\Python313\\python.exe" scripts\\generate_validation_report.py combined-result.json'
        
                    archiveArtifacts artifacts: 'test-results.xlsx', allowEmptyArchive: false
        
                    echo '✅ Excel report generated and archived.'
                }
            }
        }
    }
}
