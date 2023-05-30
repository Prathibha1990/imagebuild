/*
NOTE:
    1. THE CURRENT VERION INCLUDED WITH IN THE ARTIFACT FILE
    2. THE VERSION FORMAT SHOULD BE FLOW THE PATTERN: 1.2.3
    3. DOCKER IMAGE NAME: docker-registry:5000/trustonic/alps-devops-infra
        - TTPv2 using with tag version 1.0.18
        - TTPv3 using with tag version 3.0.0 and later
*/

import groovy.transform.Field

@Field final String VERSION_ARTIFACTS_FILE_NAME = "alps-devops-infra-docker-version"

String getVersion(String version) {
    if (version == "auto assign") {
        copyArtifacts(
            projectName: "${env.JOB_NAME}",
            filter: "${VERSION_ARTIFACTS_FILE_NAME}",
            selector: lastSuccessful(),
            fingerprintArtifacts: true
        )
        String v = readFile(file: "${VERSION_ARTIFACTS_FILE_NAME}")
        String[] parts = v.split('\\.')
        parts[parts.size() -1] = (Integer.valueOf(parts.last()) + 1).toString()

        version = parts.join('.') 
    } else {
        assert version =~ /\d+.\d+.\d+/
    }

    return version
}

pipeline{
    agent {
        label '****'
    }

    options {
        buildDiscarder logRotator(numToKeepStr: '20')
        disableConcurrentBuilds()
        copyArtifactPermission("*")
        timestamps()
    }

    parameters{
        booleanParam(defaultValue: false, description: 'Read Jenkinsfile to refresh parameters and stop job', name: 'REFRESH')
        string(defaultValue: "23.0.0", description: 'Building docker version', name: "DOCKER_VERSION")
        string(defaultValue: "auto assign", description: 'Set new devops infra image version', name: 'DOCKER_IMAGE_VERSION')
    }

    environment{
        REFRESH = "${params.REFRESH}"
        DOCKER_REGISTRY = 'docker-registry:5000'
        DOCKER_VERSION = "${params.DOCKER_VERSION}"
        DOCKER_IMAGE_VERSION = getVersion("${params.DOCKER_IMAGE_VERSION}")
        DOCKER_SOURCE_PATH = "services/aosp"
    }

    stages{
        stage("Parameterizing First Time") {
            steps {
                script {
                    echo "BUILD_NUMBER: ${env.BUILD_NUMBER}"
                    if (env.BUILD_NUMBER.equals("1") && currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause') != null) {
                        currentBuild.displayName = "#${env.BUILD_NUMBER}  Parameters loading..."
                        currentBuild.result = 'ABORTED'
                        error "DRY RUN COMPLETED. JOB PARAMETERIZED."
                    }
                }
            }
        }

        stage("Parameterizing N Time") {
          when {
                expression { params.REFRESH == true }
            }
            steps {
                script {
                    currentBuild.result = 'ABORTED'
                    currentBuild.displayName = "#${env.BUILD_NUMBER}  Parameters loading..."
                    error "DRY RUN COMPLETED. JOB PARAMETERIZED."
                }
            }
        }

        stage("Build AOSP Image") {
            steps {
                script{
                    sh """
                        cd ${DOCKER_SOURCE_PATH}
                        docker build --force-rm -t ${DOCKER_REGISTRY}/trustonic/alps-devops-aosp:${DOCKER_IMAGE_VERSION} --build-arg DOCKER_VERSION=${DOCKER_VERSION} .
                        docker push ${DOCKER_REGISTRY}/trustonic/alps-devops-aosp:${DOCKER_IMAGE_VERSION}                        
                        docker image prune -f                        
                    """

                    sh "echo -n ${DOCKER_IMAGE_VERSION} > ${VERSION_ARTIFACTS_FILE_NAME}"
                }
            }
        }
    }
      post {
        always {
            archiveArtifacts artifacts: VERSION_ARTIFACTS_FILE_NAME,
                allowEmptyArchive: true,
                fingerprint: true,
                onlyIfSuccessful: true
            cleanWs()
        }
    }
}
