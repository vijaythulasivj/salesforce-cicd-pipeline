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
        SF_CMD = '"C:\\Program Files\\sf\\bin\\sf.cmd"'
        ALIAS = "myAlias"
        INSTANCE_URL = "https://test.salesforce.com"
        PYTHON_EXE = '"C:\\Users\\tsi082\\AppData\\Local\\Programs\\Python\\Python313\\python.exe"'
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
                        --instance-url %INSTANCE_URL% ^
                        --alias %ALIAS% ^
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

                    echo '📦 Preparing destructive deployment ZIP...'
                    bat '''
                        rmdir /s /q destructive-temp || exit 0
                        mkdir destructive-temp
                        copy destructive\\destructiveChanges.xml destructive-temp\\
                        copy destructive\\package.xml destructive-temp\\
                        powershell Compress-Archive -Path destructive-temp\\* -DestinationPath destructivePackage.zip -Force
                    '''

                    echo '📦 Listing contents of destructivePackage.zip:'
                    bat '''
                        powershell -command "Add-Type -AssemblyName System.IO.Compression.FileSystem; $zipPath = 'destructivePackage.zip'; $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath); $zip.Entries | ForEach-Object { Write-Output $_.FullName }; $zip.Dispose()"
                    '''

                    echo '🔧 Validating destructiveChanges.xml using sfdx force:mdapi:deploy (check only)...'
                    bat """
                        "C:\\Users\\tsi082\\AppData\\Roaming\\npm\\sfdx.cmd" force:mdapi:deploy ^
                            --zipfile destructivePackage.zip ^
                            --targetusername %ALIAS% ^
                            --wait 10 ^
                            --checkonly ^
                            --json > deploy-result.json
                    """

                    echo '📂 Archiving deploy-result.json...'
                    archiveArtifacts artifacts: 'deploy-result.json', allowEmptyArchive: false

                    echo '✅ Validation of destructiveChanges.xml complete.'

                    bat """
                    %SF_CMD% deploy metadata validate ^
                        --source-dir force-app/main/default/classes ^
                        --target-org %ALIAS% ^
                        --test-level RunSpecifiedTests ^
                        --tests ASKYTightestMatchServiceImplTest ^
                        --json > deploy-result.json
                    """        
                    echo '🧪 Running Apex tests (initial run to get testRunId)...'
                    bat """
                    %SF_CMD% apex run test ^
                        --tests ASKYTightestMatchServiceImplTest ^
                        --target-org %ALIAS% ^
                        --code-coverage ^
                        --test-level RunSpecifiedTests ^
                        --json > test-run.json
                    """
        
                    // ✅ Extract testRunId from test-run.json using Jenkins readJSON
                    def testRunJson = readJSON file: 'test-run.json'
                    def testRunId = testRunJson?.result?.testRunId?.trim()
        
                    if (!testRunId) {
                        error "❌ testRunId not found in test-run.json! Failing pipeline."
                    }
        
                    echo "➡️ Test Run ID: ${testRunId}"
        
                    echo '🧪 Fetching detailed test results from REST API and generating Excel report...'
                    withEnv([
                        "TEST_RUN_ID=${testRunId}",
                        "SF_ALIAS=${env.ALIAS}",
                        "PYTHONIOENCODING=utf-8"
                    ]) {
                        bat "\"${env.PYTHON_EXE}\" scripts\\generate_validation_report.py"
                    }
        
                    echo '📂 Archiving Excel report...'
                    archiveArtifacts artifacts: 'test-results.xlsx', allowEmptyArchive: false
        
                    echo '✅ Excel report generated and archived.'
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
        SF_CMD = '"C:\\Program Files\\sf\\bin\\sf.cmd"'
        SFDX_CMD = '"C:\\Users\\tsi082\\AppData\\Roaming\\npm\\sfdx.cmd"'
        ALIAS = "myAlias"
        INSTANCE_URL = "https://test.salesforce.com"
        PYTHON_EXE = '"C:\\Users\\tsi082\\AppData\\Local\\Programs\\Python\\Python313\\python.exe"'
    }

    parameters {
        booleanParam(name: 'REDEPLOY_METADATA', defaultValue: false, description: 'Redeploy previously backed-up metadata?')
    }

    stages {
        stage('Authenticate Salesforce') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                    %SF_CMD% auth jwt grant ^
                        --client-id %CONSUMER_KEY% ^
                        --jwt-key-file "%JWT_KEY%" ^
                        --username %SF_USERNAME% ^
                        --instance-url %INSTANCE_URL% ^
                        --alias %ALIAS% ^
                        --set-default ^
                        --no-prompt
                    """
                    bat 'echo Authenticated successfully.'
                }
            }
        }

        stage('Generate package.xml from destructiveChanges.xml') {
            steps {
                echo 'Generating package.xml from destructiveChanges.xml...'
                writeFile file: 'generate_package_xml.ps1', text: '''
                [xml]$xml = Get-Content destructive\\destructiveChanges.xml

                $typesDict = @{}

                foreach ($type in $xml.Package.types) {
                    $typeName = $type.name
                    if (-not $typesDict.ContainsKey($typeName)) {
                        $typesDict[$typeName] = @()
                    }

                    foreach ($member in $type.members) {
                        $typesDict[$typeName] += $member
                    }
                }

                $packageXml = @()
                $packageXml += '<?xml version="1.0" encoding="UTF-8"?>'
                $packageXml += '<Package xmlns="http://soap.sforce.com/2006/04/metadata">'

                foreach ($typeName in $typesDict.Keys) {
                    $packageXml += "  <types>"
                    foreach ($member in $typesDict[$typeName]) {
                        $packageXml += "    <members>$member</members>"
                    }
                    $packageXml += "    <name>$typeName</name>"
                    $packageXml += "  </types>"
                }

                $packageXml += "  <version>64.0</version>"
                $packageXml += "</Package>"

                $packageXml | Out-File -FilePath destructive\\package.xml -Encoding UTF8
                '''.stripIndent()

                bat 'powershell -NoProfile -ExecutionPolicy Bypass -File generate_package_xml.ps1'
                echo '✅ package.xml generated.'
                bat 'type destructive\\package.xml'
            }
        }

        stage('Retrieve Metadata from Org') {
            steps {
                script {
                    echo 'Retrieving metadata package from org...'
                    bat 'if exist unpackaged rmdir /s /q unpackaged'
        
                    def retrieveStatus = bat(
                        script: """
                            ${env.SFDX_CMD} force:mdapi:retrieve ^
                                --retrievetargetdir unpackaged ^
                                --unpackaged destructive\\package.xml ^
                                --targetusername %ALIAS% ^
                                --wait 20 ^
                                --json ^
                                --loglevel debug > retrieve-result.json
                        """,
                        returnStatus: true
                    )
        
                    bat 'type retrieve-result.json'
                    def retrieveJson = readJSON file: 'retrieve-result.json'
        
                    if (retrieveStatus != 0 || retrieveJson.result?.messages) {
                        def message = retrieveJson.result?.messages?.problem ?: 'Unknown metadata retrieval error'
                        echo "❌ Metadata retrieve failed: ${message}"
                        error "Metadata validation failed due to missing metadata in org: ${message}"
                    }
        
                    echo '✅ Metadata retrieved successfully.'
                    bat 'powershell -Command "Expand-Archive -Path unpackaged\\unpackaged.zip -DestinationPath unpackaged -Force"'
                    echo 'Metadata retrieved and extracted to unpackaged directory.'
        
                    // ✅ Backup for redeployment
                    archiveArtifacts artifacts: 'unpackaged/unpackaged.zip', fingerprint: true
                    bat 'copy unpackaged\\unpackaged.zip retrieved-metadata.zip'
                    archiveArtifacts artifacts: 'retrieved-metadata.zip'
                }
            }
        }

        stage('Validate Destructive Deployment') {
            steps {
                script {
                    echo 'Parsing metadata components from destructiveChanges.xml...'
                    bat 'dir destructive'
                    bat 'type destructive\\destructiveChanges.xml'

                    writeFile file: 'extract_metadata.ps1', text: '''
                    [xml]$xml = Get-Content destructive\\destructiveChanges.xml
                    $components = @()
                    foreach ($type in $xml.Package.types) {
                        $metaType = $type.name
                        foreach ($member in $type.members) {
                            $components += "$($metaType):$($member)"
                        }
                    }
                    $components -join ","
                    '''.stripIndent()

                    echo 'Running PowerShell parsing script...'
                    def rawOutput = bat(
                        script: 'powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File extract_metadata.ps1',
                        returnStdout: true
                    ).trim()
                    echo "Parsed components: ${rawOutput}"

                    echo 'Preparing destructive deployment package...'
                    bat 'if exist destructiveDeployment.zip del destructiveDeployment.zip'
                    bat '''
                    copy destructive\\destructiveChanges.xml .
                    copy destructive\\package.xml .
                    powershell -Command "Compress-Archive -Path destructiveChanges.xml,package.xml -DestinationPath destructiveDeployment.zip -Force"
                    del destructiveChanges.xml
                    del package.xml
                    '''

                    echo 'Running dry-run deployment (checkonly) to validate destructive changes...'
                    timeout(time: 20, unit: 'MINUTES') {
                        def deployStatus = bat(
                            script: """
                                ${env.SFDX_CMD} force:mdapi:deploy ^
                                    --zipfile destructiveDeployment.zip ^
                                    --targetusername  %ALIAS%^
                                    --wait 20 ^
                                    --checkonly ^
                                    --json ^
                                    --loglevel debug > deploy-result.json
                            """,
                            returnStatus: true
                        )

                        bat 'type deploy-result.json'

                        def deployJson = readJSON file: 'deploy-result.json'
                        def result = deployJson.result

                        if (deployStatus != 0 || !result.success) {
                            def failures = result?.details?.componentFailures
                            def errorMessages = []

                            if (failures) {
                                if (failures instanceof Map) {
                                    errorMessages << "${failures.problemType}: ${failures.problem}"
                                } else if (failures instanceof List) {
                                    for (f in failures) {
                                        errorMessages << "${f.problemType}: ${f.problem}"
                                    }
                                }

                                echo "🚨 Deployment failed due to the following reason(s):"
                                for (msg in errorMessages) {
                                    echo "❌ $msg"
                                }
                            } else {
                                echo "❌ Deployment failed, but no specific component errors found."
                            }

                            error("Dry-run deployment validation failed due to missing metadata or other issues.")
                        }

                        echo "📊 Deployment Summary:"
                        echo "🔢 numberComponentsTotal: ${result.numberComponentsTotal}"
                        echo "✅ numberComponentsDeployed: ${result.numberComponentsDeployed}"
                        echo "❌ numberComponentErrors: ${result.numberComponentErrors}"
                        echo "📦 Deployment Status: ${result.status}"
                        echo "🔁 Rollback On Error: ${result.rollbackOnError}"
                    }
                }
            }
        }

        stage('✅ Diagnostic Checks for Destructive Deployment') {
            steps {
                script {
                    echo "🔍 Step A: Validate ZIP Structure..."
        
                    // Extract the ZIP contents to a temp folder
                    bat '''
                    rmdir /s /q zipcheck || exit 0
                    mkdir zipcheck
                    powershell -Command "Expand-Archive -Path destructiveDeployment.zip -DestinationPath zipcheck -Force"
                    dir zipcheck
                    '''
        
                    echo "✅ ZIP structure checked. It should contain only: destructiveChanges.xml and package.xml"
        
                    echo "🔍 Step B: Check Metadata Availability in Org..."
        
                    // Describe metadata (overview)
                    bat '"C:\\Users\\tsi082\\AppData\\Roaming\\npm\\sfdx.cmd" force:mdapi:describemetadata -u myAlias --json > describe-metadata.json'
                    bat 'type describe-metadata.json'
        
                    // List ApexClass metadata specifically
                    bat '"C:\\Users\\tsi082\\AppData\\Roaming\\npm\\sfdx.cmd" force:mdapi:listmetadata -m ApexClass -u myAlias --json > list-apexclass.json'
                    bat 'type list-apexclass.json'
        
                    echo "✅ Metadata listing complete. Confirm the class names are present and case-sensitive."
        
                    echo "🔍 Step C: Try Destructive Deployment with --verbose flag..."
        
                    // Re-run destructive deployment with verbose logging
                    bat '"C:\\Users\\tsi082\\AppData\\Roaming\\npm\\sfdx.cmd" force:mdapi:deploy --zipfile destructiveDeployment.zip --targetusername myAlias --wait 20 --ignorewarnings --verbose --json > verbose-deploy-result.json'
        
                    // Output verbose deployment result
                    bat 'type verbose-deploy-result.json'
        
                    echo "✅ Verbose deployment run complete. Analyze output for skipped or ignored metadata."
                }
            }
        }

        stage('Delete Metadata (Destructive Deployment)') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        echo '🚨 Deleting metadata using destructiveChanges.xml...'
                        def deleteStatus = bat(
                            script: """
                                ${env.SFDX_CMD} force:mdapi:deploy ^
                                    --zipfile destructiveDeployment.zip ^
                                    --targetusername %ALIAS% ^
                                    --wait 20 ^
                                    --ignorewarnings ^
                                    --singlepackage ^
                                    --json > destructive-delete-result.json
                            """,
                            returnStatus: true
                        )

                        bat 'type destructive-delete-result.json'

                        def deleteJson = readJSON file: 'destructive-delete-result.json'
                        def result = deleteJson.result

                        if (deleteStatus != 0 || !result.success) {
                            def failures = result?.details?.componentFailures
                            def errorMessages = []

                            if (failures) {
                                if (failures instanceof Map) {
                                    errorMessages << "${failures.problemType}: ${failures.problem}"
                                } else if (failures instanceof List) {
                                    for (f in failures) {
                                        errorMessages << "${f.problemType}: ${f.problem}"
                                    }
                                }

                                echo "🚨 Deletion failed due to the following reason(s):"
                                for (msg in errorMessages) {
                                    echo "❌ $msg"
                                }
                            } else {
                                echo "❌ Destructive deployment failed with unknown error."
                            }

                            error("Destructive deployment (delete) failed.")
                        }

                        echo "📊 Deletion Summary:"
                        echo "🔢 numberComponentsTotal: ${result.numberComponentsTotal}"
                        echo "✅ numberComponentsDeployed: ${result.numberComponentsDeployed}"
                        echo "❌ numberComponentErrors: ${result.numberComponentErrors}"
                        echo "📦 Deletion Status: ${result.status}"
                        echo "🔁 Rollback On Error: ${result.rollbackOnError}"
                    }
                }
            }
        }

        stage('Verify Metadata Deletion') {
            steps {
                script {
                    echo "Verifying deletion by retrieving metadata again..."

                    bat 'if exist verify rmdir /s /q verify'
                    bat """
                        ${env.SFDX_CMD} force:mdapi:retrieve ^
                            --retrievetargetdir verify ^
                            --unpackaged destructive\\package.xml ^
                            --targetusername %ALIAS% ^
                            --wait 20 ^
                            --json > verify-retrieve.json
                    """

                    def verifyJson = readJSON file: 'verify-retrieve.json'

                    if (verifyJson.result?.fileProperties?.size() > 0) {
                        echo "❌ Some components were not deleted:"
                        verifyJson.result.fileProperties.each { f ->
                            echo " - ${f.type}:${f.fullName}"
                        }
                        error("Destructive deployment did not delete all components.")
                    } else {
                        echo "✅ All targeted metadata components were successfully deleted."
                    }
                }
            }
        }



        stage('📦 Step 6: Redeploy from Backup (Optional Manual Trigger)') {
            when {
                expression { return params.REDEPLOY_METADATA }
            }
            steps {
                echo "📤 Redeploying previously retrieved metadata…"

                copyArtifacts(
                    projectName: env.JOB_NAME,
                    filter: 'retrieved-metadata.zip',
                    selector: lastSuccessful()
                )

                script {
                    if (!fileExists('retrieved-metadata.zip')) {
                        error "❌ Could not retrieve 'retrieved-metadata.zip'. Redeploy cancelled."
                    }
                }

                bat 'powershell Expand-Archive -Path retrieved-metadata.zip -DestinationPath retrieved-metadata -Force'

                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                        %SF_CMD% project deploy start ^
                            --target-org %SF_USERNAME% ^
                            --source-dir retrieved-metadata ^
                            --ignore-warnings ^
                            --wait 10
                    """
                }
            }
        }




        /*
        stage('Validate Destructive Deployment') {
            when { expression { !params.REDEPLOY_METADATA } }
            steps {
                script {
                    echo 'Parsing metadata components from destructiveChanges.xml...'
        
                    // Step 1: Extract metadata components to retrieve
                    writeFile file: 'extract_metadata.py', text: '''
                    import xml.etree.ElementTree as ET
                    destructive_xml = "destructive/destructiveChanges.xml"
                    tree = ET.parse(destructive_xml)
                    root = tree.getroot()
                    ns = {"sf": "http://soap.sforce.com/2006/04/metadata"}
                    
                    components = []
                    for t in root.findall("sf:types", ns):
                        meta_type = t.find("sf:name", ns).text
                        members = [m.text for m in t.findall("sf:members", ns)]
                        for member in members:
                            components.append(f"{meta_type}:{member}")
                    
                    print(",".join(components))
                                '''.stripIndent()
        
                    def rawOutput = bat(
                        script: "${env.PYTHON_EXE} extract_metadata.py",
                        returnStdout: true
                    ).trim()
        
                    // Grab only the last non-empty line (which is our metadata list)
                    def metadataComponents = rawOutput.readLines().findAll { it?.trim() }[-1]
                    echo "✅ Components to retrieve:\n${metadataComponents}"
        
                    // Step 2: Clean old retrieve folder
                    bat 'if exist retrieved_metadata rmdir /s /q retrieved_metadata'
        
                    // Step 3: Retrieve metadata using sf CLI
                    echo '📦 Retrieving metadata from org...'
                    def retrieveStatus = bat(
                        script: """
                            ${env.SF_CMD} metadata retrieve ^
                                --target-org %ALIAS% ^
                                --output-dir retrieved_metadata ^
                                --metadata "${metadataComponents}" ^
                                --wait 10
                        """,
                        returnStatus: true
                    )
        
                    if (retrieveStatus != 0 || !fileExists('retrieved_metadata/unpackaged.zip')) {
                        error "❌ Metadata retrieval failed or ZIP not found."
                    }
        
                    // Step 4: Unzip retrieved metadata
                    echo '📂 Unzipping retrieved metadata...'
                    bat 'powershell -Command "Expand-Archive -Path retrieved_metadata\\unpackaged.zip -DestinationPath unpackaged -Force"'
        
                    // Step 5: Add destructive files to unpackaged
                    echo '📝 Adding destructiveChanges.xml and package.xml...'
                    bat """
                        copy destructive\\destructiveChanges.xml unpackaged\\
                        copy destructive\\package.xml unpackaged\\
                    """
        
                    // Step 6: Zip everything
                    echo '🗜️ Zipping all into destructiveDeployment.zip...'
                    bat 'powershell -Command "Compress-Archive -Path unpackaged\\* -DestinationPath destructiveDeployment.zip -Force"'
        
                    // Step 7: Run checkonly (dry run) deploy
                    echo '🚀 Running dry-run validation...'
                    def deployStatus = bat(
                        script: """
                            ${env.SFDX_CMD} force:mdapi:deploy ^
                                --zipfile destructiveDeployment.zip ^
                                --targetusername %ALIAS% ^
                                --wait 10 ^
                                --checkonly ^
                                --json > deploy-result.json
                        """,
                        returnStatus: true
                    )
        
                    if (deployStatus != 0) {
                        echo "❌ Validation failed. Output:"
                        bat 'type deploy-result.json'
                        error "Dry-run deployment validation failed."
                    } else {
                        echo "✅ Dry-run deployment succeeded. Output:"
                        bat 'type deploy-result.json'
                    }
                    
                    echo 'Validating metadata existence in sandbox using Python...'
        
                    def validateScript = '''
                    import xml.etree.ElementTree as ET
                    import subprocess
                    import sys
                    import json
                    import os
                    
                    ORG_ALIAS = os.environ.get('ALIAS')
                    SFDX_CLI = os.environ.get('SF_CMD', 'sfdx').strip('"')
                    
                    SOQL_MAP = {
                        'ApexClass': "SELECT Id FROM ApexClass WHERE Name = '{}'",
                        'ApexTrigger': "SELECT Id FROM ApexTrigger WHERE Name = '{}'",
                        'ApexPage': "SELECT Id FROM ApexPage WHERE Name = '{}'"
                    }
                    
                    def check_component_exists(metadata_type, component_name):
                        soql = SOQL_MAP.get(metadata_type)
                        if not soql:
                            print(f"Warning: Metadata type '{metadata_type}' not checked.")
                            return True
                    
                        query = soql.format(component_name)
                        cmd = [SFDX_CLI, 'force:data:soql:query', '-q', query, '-u', ORG_ALIAS, '--json']
                        try:
                            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
                            data = json.loads(result.stdout)
                            records = data.get("result", {}).get("records", [])
                            if not records:
                                print(f"Component NOT FOUND: {metadata_type} - {component_name}")
                                return False
                            else:
                                print(f"Component found: {metadata_type} - {component_name}")
                                return True
                        except subprocess.CalledProcessError as e:
                            print("Error running sfdx:", e)
                            return False
                    
                    def main():
                        tree = ET.parse("destructive/destructiveChanges.xml")
                        root = tree.getroot()
                        ns = {"sf": "http://soap.sforce.com/2006/04/metadata"}
                    
                        all_exist = True
                        for types in root.findall("sf:types", ns):
                            metadata_type = types.find("sf:name", ns).text
                            for member in types.findall("sf:members", ns):
                                component = member.text
                                if not check_component_exists(metadata_type, component):
                                    all_exist = False
                    
                        if not all_exist:
                            sys.exit(1)
                        else:
                            print("All metadata components exist.")
                    
                    if __name__ == "__main__":
                        main()
                    '''.stripIndent()
        
                    writeFile file: 'validate_metadata.py', text: validateScript
        
                    echo 'Running Python validation script...'
                    withEnv(["SF_CMD=${env.SF_CMD}", "ALIAS=${env.ALIAS}"]) {
                        def validateResult = bat(script: "\"${env.PYTHON_EXE}\" validate_metadata.py", returnStatus: true)
                        if (validateResult != 0) {
                            error 'One or more metadata components listed in destructiveChanges.xml do not exist in the target org. Aborting deployment.'
                        }
                    }
        
                    echo 'All metadata components exist in sandbox. Proceeding with dry-run deployment...'
                
                    
                    
                    echo 'Archiving deployment result...'
                    archiveArtifacts artifacts: 'deploy-result.json', allowEmptyArchive: false

                    echo 'Parsing result (component successes & failures)...'
                    bat """
                    echo import json > parse_deploy_result.py
                    echo with open('deploy-result.json') as f: >> parse_deploy_result.py
                    echo.    data = json.load(f) >> parse_deploy_result.py
                    echo.    details = data.get('result', {}).get('details', {}) >> parse_deploy_result.py
                    echo.    successes = details.get('componentSuccesses', []) >> parse_deploy_result.py
                    echo.    failures = details.get('componentFailures', []) >> parse_deploy_result.py
                    echo.    if isinstance(successes, dict): successes = [successes] >> parse_deploy_result.py
                    echo.    if isinstance(failures, dict): failures = [failures] >> parse_deploy_result.py
                    echo.    print('--- Component Successes ---') >> parse_deploy_result.py
                    echo.    [print(f"✓ {c.get('componentType')}: {c.get('fullName')}") for c in successes] >> parse_deploy_result.py
                    echo.    if not successes: print('No components were validated.') >> parse_deploy_result.py
                    echo.    print('\\n--- Component Failures ---') >> parse_deploy_result.py
                    echo.    [print(f" {c.get('componentType')}: {c.get('fullName')} — {c.get('problem')}") for c in failures] >> parse_deploy_result.py
                    ${env.PYTHON_EXE} parse_deploy_result.py
                    """

                    echo 'Validation complete. Ready for actual deployment if needed.'
                
                    echo 'Checking for orphaned references before deletion...'

                    def orphanRefScript = '''
                    import xml.etree.ElementTree as ET
                    import subprocess
                    import sys
                    import json
                    import os
                    
                    ORG_ALIAS = os.environ.get('ALIAS')
                    SFDX_CLI = os.environ.get('SFDX_CMD', 'sfdx').strip('"')
                    
                    # Tooling API mapping for valid metadata types
                    TOOLING_TYPES = {
                        'ApexClass': 'ApexClass',
                        'ApexTrigger': 'ApexTrigger',
                        'ApexPage': 'ApexPage',
                        # Add more supported types as needed
                    }
                    
                    def run_sfdx_query(query, tooling=True):
                        cmd = [
                            SFDX_CLI,
                            'force:data:soql:query',
                            '-q', query,
                            '-u', ORG_ALIAS,
                            '--json'
                        ]
                        if tooling:
                            cmd.append('--usetoolingapi')
                        try:
                            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
                            return json.loads(result.stdout)
                        except subprocess.CalledProcessError as e:
                            print(f"[WARN] Failed SOQL query: {query}")
                            print(f"[ERROR] {e.stderr.strip()}")
                            return None
                    
                    def get_component_id(metadata_type, name):
                        tooling_object = TOOLING_TYPES.get(metadata_type)
                        if not tooling_object:
                            print(f"[SKIP] Metadata type '{metadata_type}' is not supported for orphan check.")
                            return None
                    
                        query = f"SELECT Id FROM {tooling_object} WHERE Name = '{name}'"
                        result = run_sfdx_query(query)
                        if not result:
                            return None
                    
                        records = result.get("result", {}).get("records", [])
                        if not records:
                            print(f"[INFO] Component {metadata_type} - {name} not found. Skipping.")
                            return None
                    
                        return records[0]['Id']
                    
                    def check_references(component_id, metadata_type, name):
                        query = (
                            f"SELECT MetadataComponentId, MetadataComponentName, MetadataComponentType "
                            f"FROM MetadataComponentDependency "
                            f"WHERE RefMetadataComponentId = '{component_id}'"
                        )
                        result = run_sfdx_query(query)
                        if not result:
                            print(f"[WARN] Unable to fetch references for {metadata_type} - {name}")
                            return False
                    
                        references = result.get("result", {}).get("records", [])
                        if references:
                            print(f"[ERROR] {metadata_type} - {name} is referenced by:")
                            for ref in references:
                                ref_name = ref.get("MetadataComponentName", "Unknown")
                                ref_type = ref.get("MetadataComponentType", "Unknown")
                                print(f"  - {ref_type}: {ref_name}")
                            return True
                    
                        print(f"[OK] {metadata_type} - {name} has no references.")
                        return False

                    def main():
                        tree = ET.parse("destructive/destructiveChanges.xml")
                        root = tree.getroot()
                        ns = {"sf": "http://soap.sforce.com/2006/04/metadata"}
                    
                        has_references = False
                    
                        for types in root.findall("sf:types", ns):
                            metadata_type = types.find("sf:name", ns).text
                            for member in types.findall("sf:members", ns):
                                component = member.text
                                component_id = get_component_id(metadata_type, component)
                                if component_id:
                                    if check_references(component_id, metadata_type, component):
                                        has_references = True
                    
                        if has_references:
                            print("[ABORT] One or more components are still referenced. Cannot delete.")
                            sys.exit(1)
                        else:
                            print("[SUCCESS] No orphaned references found. Safe to proceed.")
                    
                    if __name__ == "__main__":
                        main()
                    '''.stripIndent()
                    
                    writeFile file: 'check_orphan_refs.py', text: orphanRefScript
                    
                    echo 'Running orphan references validation...'
                    withEnv(["SFDX_CMD=${env.SFDX_CMD}", "ALIAS=${env.ALIAS}"]) {
                        def orphanCheckResult = bat(script: "\"${env.PYTHON_EXE}\" check_orphan_refs.py", returnStatus: true)
                        if (orphanCheckResult != 0) {
                            error 'Orphaned references detected. Aborting pipeline.'
                        }
                    }
                    
                    echo 'Orphan references check passed.' 
            
                }
            }
        }
        */
    }
}








