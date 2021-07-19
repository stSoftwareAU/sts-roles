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

        stage('Build') {

            agent {
                docker{
                    image 'dga-tools:latest'
                    args '--volume /var/run/docker.sock:/var/run/docker.sock --volume /tmp:/tmp'
                }
            }
            options {
                timeout(time: 1, unit: 'HOURS')
            }
            steps {

                sh '''\
                    build.sh
                    push.sh
                '''.stripIndent()

                sh './release.sh'
            }
        }

        stage('Release') {

            agent {
                docker{
                    image 'dga-tools:latest'
                    args '--volume /var/run/docker.sock:/var/run/docker.sock --volume /tmp:/tmp'
                }
            }
            options {
                timeout(time: 1, unit: 'HOURS')
            }
            steps {

                sh '''\
                    release.sh
                '''.stripIndent()

            }
        }
    }
}
