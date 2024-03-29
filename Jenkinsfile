/*
 * WARNING: Automatically copied from dga-tools
 */
TOOLS_IMAGE = "${ECR}/develop/sts-tools:latest"
TOOLS_ARGS = '--volume /var/run/docker.sock:/var/run/docker.sock --volume /tmp:/tmp'
pipeline {
  agent none

  triggers {
    pollSCM( '* * * * *')
    cron( 'H H(2-3) * * H(2-4)') // UTC About Midday Sydney time on a workday.
  }

  options {
    timeout(time: 1, unit: 'HOURS')
    disableConcurrentBuilds()
    parallelsAlwaysFailFast()
  }

  stages {
    stage('Build') {

      when {
        environment name: 'CHANGE_ID', value: '' // Not a Pull Request
        beforeAgent true
      }

      agent {
        docker {
          image TOOLS_IMAGE
          args TOOLS_ARGS
        }
      }

      steps {
        sh '''\
          #!/bin/bash
          set -ex

          /home/tools/build.sh
          /home/tools/push.sh
        '''.stripIndent()
      }
    }

    stage('QA') {
      parallel {
        stage('validate') {
          when {
            environment name: 'CHANGE_ID', value: '' // Not a Pull Request
            beforeAgent true
          }

          agent {
            docker {
              image TOOLS_IMAGE
              args TOOLS_ARGS
            }
          }
          steps {
            sh '''\
              #!/bin/bash
              set -ex

              /home/tools/pull.sh
              /home/tools/run.sh --require 3.7 --mode validate
            '''.stripIndent()
          }
        }

        stage('CVE scan') {
          when {
            allOf {
              not { anyOf { branch 'Staging'; branch 'Production'; branch 'Identity'; branch 'Pipeline' } }
              environment name: 'CHANGE_ID', value: '' // Not a Pull Request
            }
            beforeAgent true
          }
          agent {
            docker {
              image TOOLS_IMAGE
              args TOOLS_ARGS
            }
          }

          steps {
            script {
              try {
                sh '''\
                  #!/bin/bash
                  set -ex

                  /home/tools/cve-scan.sh
                '''.stripIndent()
                env.CVE_SCAN_FAILED = false
              }
              catch (err) {
                echo "Caught: ${err}"
                env.CVE_SCAN_FAILED = true
              }
            }
          }
          post {
            always {
              archiveArtifacts artifacts: 'cve-scan.json', fingerprint: true
            }
          }
        }
      }
    }

    stage('Prompt') {
      agent none

      when {
        expression { env.CVE_SCAN_FAILED == 'true' }
      }

      steps {
        script {
          timeout(time: 15, unit: 'MINUTES') {
            input( message: 'CVE scan detected issues', ok: 'Continue?')
          }
        }
      }
    }

    stage('Release') {
      when {
        environment name: 'CHANGE_ID', value: ''
        beforeAgent true
      }

      agent {
        docker {
          image TOOLS_IMAGE
          args TOOLS_ARGS
        }
      }

      steps {
        sh '''\
          #!/bin/bash
          set -ex

          /home/tools/release.sh
        '''.stripIndent()
      }
    }
  }
}
