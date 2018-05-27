#!groovy
REPO_NAME = "${currentBuild.rawBuild.project.parent.displayName.toLowerCase()}"
BRANCH_NAME = "${env.BRANCH_NAME.replaceAll(/[\/]/, '-').toLowerCase()}"

IMAGE_TAG_COMPLETE = "${BRANCH_NAME}-${env.BUILD_ID}"
IMAGE_NAME_COMPLETE = "${REPO_NAME}:${IMAGE_TAG_COMPLETE}"
SERVICE_NAME = "${REPO_NAME}-${BRANCH_NAME}"
TARGET_OPC_PROJECT = "${env.OCP_ACMF_NS}"
TARGET_IMAGE = "${SERVICE_NAME}:${IMAGE_TAG_COMPLETE}"


pipeline {
  agent any

  tools {
    nodejs 'NodeJS 7.4.0'
  }

  stages {
    stage("Build Image and Publish to Nexus") {
      steps {
        script {
          sh "docker build . -t ${IMAGE_NAME_COMPLETE} -f WebAPIOther.Dockerfile"
          def image = docker.image("${IMAGE_NAME_COMPLETE}")
          docker.withRegistry("https://${env.NEXUS_DEV_DOCKER_REGISTRY}", 'NEXUS_AUTH') {
            image.push()
          }
        }
      }
    }

    stage("Deploy to Openshift") {
      steps {
        script {
         
          try {
            withCredentials([usernamePassword(credentialsId: 'OCP_AUTH', usernameVariable: 'OCP_USERNAME', passwordVariable: 'OCP_PASSWORD')]) {
              sh """
                oc login ${env.OPENSHIFT_API_URL} --username ${OCP_USERNAME} --password ${OCP_PASSWORD} --insecure-skip-tls-verify
                oc project ${TARGET_OPC_PROJECT}
                oc process -f openshift_template.yaml -p NAMESPACE=${TARGET_OPC_PROJECT} -p REGISTRY=${env.NEXUS_DEV_DOCKER_REGISTRY} -p IMAGE_NAME=${REPO_NAME} -p IMAGE_TAG=${IMAGE_TAG_COMPLETE} -p SERVICE_NAME=${SERVICE_NAME} | oc apply -f - -n ${TARGET_OPC_PROJECT}
                oc import-image ${TARGET_IMAGE} --confirm --insecure | grep -i "successfully"
              """
            }
          } catch(e) {
            error(e)
          }
        }
      }
    }
  }
}