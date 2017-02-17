#!/usr/bin/groovy
@Library('github.com/fabric8io/fabric8-pipeline-library@master')
def dummy
deployTemplate{
  mavenNode {
    ws{
      checkout scm
      sh "git remote set-url origin git@github.com:fabric8io/fabric8-platform.git"

      def pipeline = load 'release.groovy'

      stage 'Stage'
      def stagedProject = pipeline.stage()

      stage 'Deploy and run system tests'
      def yaml = readFile file: "packages/fabric8-platform/target/classes/META-INF/fabric8/kubernetes.yml"
      fabric8SystemTests {
          packageYAML = yaml
      }

      stage 'Approve'
      pipeline.approve(stagedProject)

      stage 'Promote'
      pipeline.release(stagedProject)
    }
  }
}