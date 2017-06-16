#!/usr/bin/groovy
@Library('github.com/fabric8io/fabric8-pipeline-library@master')
def utils = new io.fabric8.Utils()
deployTemplate {
  mavenNode {
    ws {
      try {
        checkout scm
        readTrusted 'release.groovy'

        if (utils.isCI()) {

          echo 'CI is not handled by pipelines yet'

        } else if (utils.isCD()) {
          sh "git remote set-url origin git@github.com:fabric8io/fabric8-platform.git"

          def pipeline = load 'release.groovy'
          def stagedProject

          stage('Stage') {
            stagedProject = pipeline.stage()
          }

/*
        stage('Deploy and run system tests') {
          def yamlKube = readFile file: "packages/fabric8-system/target/classes/META-INF/fabric8/kubernetes.yml"
          fabric8SystemTests {
            packageYAML = yamlKube
          }
        }

        stage('Approve') {
          pipeline.approve(stagedProject)
        }
*/

          stage('Promote') {
            pipeline.release(stagedProject)
          }

          stage('Promote YAMLs') {
            def yamlKube = readFile file: "packages/fabric8-system/target/classes/META-INF/fabric8/kubernetes.yml"
            def yamlOS = readFile file: "packages/fabric8-system/target/classes/META-INF/fabric8/openshift.yml"
            pipeline.promoteYamls(stagedProject, yamlKube, yamlOS)
          }
        }
      } catch (err) {
        hubot room: 'release', message: "${env.JOB_NAME} failed: ${err}"
        error "${err}"
      }
    }
  }
}