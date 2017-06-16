#!/usr/bin/groovy
@Library('github.com/fabric8io/fabric8-pipeline-library@master')
def dummy
deployTemplate{
  mavenNode {
    ws{
      checkout scm
      sh "git remote set-url origin git@github.com:fabric8io/fabric8-platform.git"

      def pipeline = load 'release.groovy'
      def stagedProject = null
      def yamlKube = null
      def yamlOS = null

      stage ('Stage') {
        stagedProject = pipeline.stage()
      }

      stage ('Deploy and run system tests') {
        def yamlKube = readFile file: "packages/fabric8-system/target/classes/META-INF/fabric8/kubernetes.yml"
        def yamlOS = readFile file: "packages/fabric8-system/target/classes/META-INF/fabric8/openshift.yml"
        fabric8SystemTests {
            packageYAML = yamlKube
        }
      }

      stage ('Approve') {
        pipeline.approve(stagedProject)
      }

      stage ('Promote') {
        pipeline.release(stagedProject)
      }

      stage ('Promote YAMLs'){
        pipeline.promoteYamls(releaseVersion, yamlKube, yamlOS)
      }
    }
  }
}