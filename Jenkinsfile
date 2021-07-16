/*
 * WARNING: Automatically copied from dga-tools
 */
pipeline {
    agent none
    triggers {
        pollSCM( '* 0-8 * * 1-5')
        cron( 'H 3 * * 3') // UTC About Midday Sydney time
    }

    environment {
        GIT_CREDENTIALS = 'e0c8abc2-7a04-4a41-96b1-1d56c0cf1874'
    }

    stages {
        stage( 'init'){
            agent {
                label 'ec2-large'
            }

            steps{
                sh '''\
                #!/bin/bash
                set -e

                tmpIdentity=$(mktemp /tmp/identity_XXXXXX.json)
                curl -s http://169.254.169.254/latest/dynamic/instance-identity/document > ${tmpIdentity}

                jq . ${tmpIdentity}
                
                echo "# Properties" > .env.properties

                ACCOUNT_ID=$(jq -r .AccountId  ${tmpIdentity})
                echo "ACCOUNT_ID=${ACCOUNT_ID}" >> .env.properties
                jq -r .AccountId  ${tmpIdentity}>> .env.properties

                REGION=$(jq -r .region  ${tmpIdentity})
                echo "REGION=${REGION}" >> .env.properties

                rm ${tmpIdentity}
                '''.stripIndent()

                // stage("readJson") {
                //     def jsonString = '{"name":"katone","age":5}'
                //     def jsonObj = readJSON text: jsonString

                //     assert jsonObj['name'] == 'katone'  // this is a comparison.  It returns true
                //     sh "echo ${jsonObj.name}"  // prints out katone
                //     sh "echo ${jsonObj.age}"   // prints out 5
                // }
            }
        }
        stage( 'hack'){
            agent {
                docker {
                    alwaysPull true
                    image "<aws-account-Id>.dkr.ecr.us-west-2.amazonaws.com/dga-tools:<tag>"
                    registryUrl 'https://<aws-account-Id>.dkr.ecr.us-west-2.amazonaws.com'
                    registryCredentialsId 'ecr:us-west-2:<Jenkins Credential ID>'
                }
            }
        }
        stage('Build') {
            
            agent {
                label 'ec2-large'
            }
            options {
                timeout(time: 1, unit: 'HOURS')
            }
            steps {
                sh '''\
                #!/bin/bash
                set -e

                tmpIdentity=$(mktemp /tmp/identity_XXXXXX.json)
                curl -s http://169.254.169.254/latest/dynamic/instance-identity/document > ${tmpIdentity}

                jq . ${tmpIdentity}
                
                echo "# Properties" > .env.properties

                ACCOUNT_ID=$(jq -r .AccountId  ${tmpIdentity})
                echo "ACCOUNT_ID=${ACCOUNT_ID}" >> .env.properties
                jq -r .AccountId  ${tmpIdentity}>> .env.properties

                REGION=$(jq -r .region  ${tmpIdentity})
                echo "REGION=${REGION}" >> .env.properties

                rm ${tmpIdentity}

                ECR="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

                aws ecr get-login-password | docker login --username AWS --password-stdin ${ECR}
                TOOLS_REPO="dga-tools"
                DOCKER_TAG="Scratch"

                DOCKER_URI="${ECR}/${TOOLS_REPO}"
                docker pull ${DOCKER_URI}:${DOCKER_TAG}
                docker tag ${DOCKER_URI}:${DOCKER_TAG} ${TOOLS_REPO}:latest
                '''.stripIndent()

                // sh './build.sh'

                // sh './push.sh'

                // sh './release.sh'
            }
        }
    }
}
