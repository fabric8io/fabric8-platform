#!/usr/bin/groovy
def updateDependencies(source){

  def properties = []
  properties << ['<fabric8.version>','io/fabric8/kubernetes-api']
  properties << ['<fabric8.maven.plugin.version>','io/fabric8/fabric8-maven-plugin']
  properties << ['<fabric8.devops.version>','io/fabric8/devops/apps/jenkins']
  properties << ['<fabric8.forge.version>','io/fabric8/devops/apps/jenkins']

  // TODO fabric8 console release version too!
}

def stage(){
  return stageProject{
    project = 'fabric8io/fabric8-platform'
    useGitTagForNextVersion = true
  }
}

def approveRelease(project){
  def releaseVersion = project[1]
  approve{
    room = null
    version = releaseVersion
    console = null
    environment = 'fabric8'
  }
}

def release(project){
  releaseProject{
    stagedProject = project
    useGitTagForNextVersion = true
    helmPush = false
    groupId = 'io.fabric8.platform.distro'
    githubOrganisation = 'fabric8io'
    artifactIdToWatchInCentral = 'distro'
    artifactExtensionToWatchInCentral = 'pom'
    promoteToDockerRegistry = 'docker.io'
    dockerOrganisation = 'fabric8'
    imagesToPromoteToDockerHub = []
    extraImagesToTag = null
  }
}

def mergePullRequest(prId){
  mergeAndWaitForPullRequest{
    project = 'fabric8io/fabric8-forge'
    pullRequestId = prId
  }

}
return this;
