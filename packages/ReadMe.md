This project packages up the apps into different forms of packaging for easier consumption:

* [Chat](http://fabric8.io/guide/chat.html) provides a [hubot](https://hubot.github.com/) integration with the DevOps infrastructure for different chat services
  * [chat-irc](chat-irc) for using IRC
  * [chat-letschat](chat-letschat) for using [Let's Chat](https://github.com/sdelements/lets-chat)
  * [chat-slack](chat-slack) for using [Slack](https://slack.com/) 
* [CD Pipeline](cd-pipeline) 
    * Continuous Delivery pipeline via [Gogs](http://gogs.io/), [Jenkins](https://jenkins-ci.org/), [Nexus](http://www.sonatype.org/nexus/), [Gerrit](https://www.gerritcodereview.com/)  and [SonarQube](http://www.sonarqube.org/)
* [Distro](distro) is a tarball of all of the main packages along with the microservices which make them up
* [Management](management):
    * [Logging](logging) provides consolidated logging and visualisation of log statements and events across your environment
    * [Metrics](metrics) provides consolidated historical metric collection and visualisation across your environment
* [Social](social) provides an Open Source issue tracker via [Taiga](https://taiga.io/) and a web based IDE via <a href="http://eclipse.org/orion/" target="orion">Orion</a> 
