#!/usr/bin/groovy
@Library('github.com/rawlingsj/fabric8-pipeline-library@master')
def dummy
mavenNode {
  ws{
    checkout scm
    sh "git remote set-url origin git@github.com:fabric8io/fabric8-platform.git"

    def pipeline = load 'release.groovy'

    stage 'Stage'
    def stagedProject = pipeline.stage()

    stage 'Approve'
    pipeline.approve(stagedProject)

    stage 'Promote'
    pipeline.release(stagedProject)
  }
}
