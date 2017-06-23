## Installing on MiniShift

The following are the instructions for installing fabric8 on minishift:


* Make sure you have a recent (3.5 of openshift or 1.5 of origin later) distribution of the `oc` binary on your `$PATH`
```
oc version
```
* If you have an old version or its not found please [download a distribution of the openshift-client-tools for your operating system](https://github.com/openshift/origin/releases/latest/) and copy the `oc` binary onto your `$PATH`

* [download the minishift distribution for your platform](https://github.com/minishift/minishift/releases) extract it and place the `minishift` binary on your `$PATH` somewhere
* start up minishift via something like this (on OS X):

```
minishift start --vm-driver=xhyve --memory=7000 --cpus=4 --disk-size=50g
```
or on any other operating system (feel free to add the `--vm-driver` parameter of your choosing):

```
minishift start --memory=7000 --cpus=4 --disk-size=50g
```

### Setup GitHub client ID and secret

We now have GitHub integration which for now requires a manual OAuth setup to obtain a clientid and secret that we will give to keycloak. 

Follow these steps using the output of:
```
echo https://keycloak-fabric8.$(minishift ip).nip.io/auth/realms/fabric8/broker/github/endpoint
```
as the Authorization callback URL and `http://fabric8.io` as a sample homepage URL.

https://developer.github.com/apps/building-integrations/setting-up-and-registering-oauth-apps/registering-oauth-apps/

![Register OAuth App](./images/register-oauth.png)


Once you have found your client ID and secret for the new fabric8 app on your github settings then type the following:

```
export GITHUB_OAUTH_CLIENT_ID=TODO
export GITHUB_OAUTH_CLIENT_SECRET=TODO
```

where the above `TODO` text is replaced by the actual client id and secret from your github settings page!

### Run the install script

* now run the [install.sh](https://github.com/fabric8io/fabric8-platform/blob/master/install.sh) script on the command line:

```
bash <(curl -s https://raw.githubusercontent.com/fabric8io/fabric8-platform/master/install.sh)
```

* if you want to install a specific version of the [fabric8 system template](http://central.maven.org/maven2/io/fabric8/platform/packages/fabric8-system/) then you can pass it on the command line as an argument. Or add the argument `local` to use a local build.


### Accept the insecure URLs in your browser

Currently there are 4 different URLS that Chrome will barf on and you'll have to explcitily click on the `ADVANCED` button then click on the URL to tell your browser its fine to trust the URLs before you can open and use the new fabric8 console

The above script should list the 4 URLs you need to open separately and approve.

We hope to figure out a nicer alternative to this issue! The problem is things like lenscript only work for public hosted URLs; whereas running locally on MiniShift we're local but use `nip.io` to provide a global URL to your local machine (to simplify having to do DNS magic on your laptop). If you fancy trying to help fix this [please check out this MiniShift issue](https://github.com/minishift/minishift/issues/1031)
