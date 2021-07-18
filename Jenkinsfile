/*
 * WARNING: Automatically copied from dga-template
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
stage ( 'hack'){
  agent {
    docker{
      pull: false
      image 'dga-tools:latest'
    }
  }


steps {
echo "hello"
sh '''\
set +e
ls -l
pwd
whoami
ls -la
docker run dga-tools:latest build
'''.stripIndent()
}
}
        stage('Build') {

            agent {
                label 'ec2-large'
            }
            options {
                timeout(time: 1, unit: 'HOURS')
            }
            environment{

                ACCOUNT_ID = sh(
                    script: "curl 'http://169.254.169.254/latest/dynamic/instance-identity/document' |jq -r .accountId",
                    returnStdout: true
                ).trim()

                REGION = sh(
                    script: "curl 'http://169.254.169.254/latest/dynamic/instance-identity/document' |jq -r .region",
                    returnStdout: true
                ).trim()
            }
            steps {

                sh './build.sh'

                sh './push.sh'

                sh './release.sh'
            }
        }
    }
}
