#!/usr/bin/groovy
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

def approve(project){
  def releaseVersion = project[1]
  def stagedPlatformKube = "https://oss.sonatype.org/content/repositories/staging/io/fabric8/platform/packages/fabric8-platform/${releaseVersion}/fabric8-platform-${releaseVersion}-kubernetes.yml"
  def stagedPlatformOpenShift = "https://oss.sonatype.org/content/repositories/staging/io/fabric8/platform/packages/fabric8-platform/${releaseVersion}/fabric8-platform-${releaseVersion}-openshift.yml"

  def proceedMessage = """
  The fabric8-platform is available for QA.  Please review and approve.

  minishift
                                                                       
  curl ${stagedPlatformOpenShift} > fabric8-platform-${releaseVersion}-openshift.yml
  gofabric8 start --minishift --package=fabric8-platform-${releaseVersion}-openshift.yml

  minikube

  curl ${stagedPlatformKube} > fabric8-platform-${releaseVersion}-kubernetes.yml
  gofabric8 start --package=fabric8-platform-${releaseVersion}-kubernetes.yml

  
  Once all the pods have started you can run a system test via:

  git clone https://github.com/fabric8io/fabric8-forge.git
  cd fabric8-forge
  ./systest.sh
  
  More details on the system tests: https://github.com/fabric8io/fabric8-forge/blob/master/fabric8-forge-rest-client/ReadMe.md
  
  Approve release?
  """

  hubotApprove message: proceedMessage, room: 'release'
  def id = approveRequestedEvent(app: "${env.JOB_NAME}", environment: 'community')

  try {
    input id: 'Proceed', message: "\n${proceedMessage}"
  } catch (err) {
    approveReceivedEvent(id: id, approved: false)
    throw err
  }
  approveReceivedEvent(id: id, approved: true)
}


def promoteYamls(releaseVersion, yamlKube, yamlOS) {
  container(name: 'clients') {
    def flow = new io.fabric8.Fabric8Commands()
    sh 'chmod 600 /root/.ssh-git/ssh-key'
    sh 'chmod 600 /root/.ssh-git/ssh-key.pub'
    sh 'chmod 700 /root/.ssh-git'


    sh 'git clone git@github.com:fabric8io/fabric8-resources.git'
    sh 'cd fabric8-resources'

    sh "git config user.email fabric8cd@gmail.com"
    sh "git config user.name fabric8-cd"

    def uid = UUID.randomUUID().toString()
    sh "git checkout -b versionUpdate${uid}"

    if (yamlKube) {
      sh "echo ${yamlKube} > fabric8-system.yml"
    }
    if (yamlOS) {
      sh "echo ${yamlOS} > fabric8-system-openshift.yml"
    }
    if (yamlKube || yamlOS) {
      def message = "Update fabric8-system YAMLs to version ${releaseVersion}"
      sh "git add *.yml"
      sh "git commit -a -m \"${message}\""
      sh "git push origin versionUpdate${uid}"
      flow.createPullRequest(message,'fabric8io/fabric8-resources',"versionUpdate${uid}")
    } else {
      echo "WARNING no YAMLS to promote!"
    }
  }
}


return this;
