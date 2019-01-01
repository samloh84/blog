---
layout: post
title:  "Building a new Virtualized Development Environment"
author: samuel
categories: [ virtualization, application-development ]
image: https://images.unsplash.com/photo-1524347258796-81291228cfc9?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2468&q=80
featured: true
hidden: false
comments: true
---

Happy New Year 2019!

I found myself in need of a new development environment, and today I got myself going down the rabbit hole of building one manually from scratch.

It's immensely satisfying to experience the feeling of a clean desktop, having all the latest software, programming languages and IDEs, along with your customizations. It feels good to have a clean slate to start from.

I also usually build a Packer script to automate the building of a virtual machine development environment, but I haven't updated my Packer script in a while. Here's my manual process, to be transcribed into a Packer script later.

### Which Hypervisor

I normally use VMWare Workstation on Windows, or VMWare Fusion on the Mac. I also use Oracle VirtualBox if for some reason I can't use Workstation, or if I need some VM to host port forwarding.

* [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [VMWare Workstation](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html)


### Which Linux

I generally use CentOS, or Fedora as my primary Linux desktop environment. I'm a fan of Ubuntu as well, but I always end up gravitating towards CentOS.

I'll grab the Minimal or Net installer and configure the GUI installer according to my setup preferences.

* [CentOS](https://www.centos.org/download/)
* Fedora [Workstation](https://getfedora.org/en/workstation/download/) or [Server](https://getfedora.org/en/server/download/)
* Ubuntu [Desktop](https://www.ubuntu.com/download/desktop) or [Server](https://www.ubuntu.com/download/server)

### Which IDE

I began using JetBrains IntelliJ IDEA since my university days. I'm so glad I did, because their IDE offerings that target all languages really make it easier to be a polyglot programmer.

Remembering programming language syntax is hard enough. JetBrains offers all the autocomplete, linting and auto formatting that modern IDEs provides, integrated with a really good plugin ecosystem and tooling that allows you to configure, run your application and its test cases. It also offers the ability to inspect your databases within the IDE, and even run SSH/terminal sessions as well. 

If I can't get JetBrains, I'll use Visual Studio Code which is also equally powerful.

I get Sublime Text 3 because it has some fancy text manipulation features that goes beyond what IntelliJ IDEA or VSCode offers.

I'll grab the JetBrains Toolbox that downloads and manages the different JetBrain IDE versions.

* [JetBrains Toolbox](https://www.jetbrains.com/toolbox/)
* [Visual Studio Code](https://code.visualstudio.com/)
* [Sublime Text 3](https://www.sublimetext.com/3)    

### Which Browser

Google Chrome. Of course. I also like Mozilla Firefox. There's only room in my heart for two browsers. I have nothing nice to say about IE or its incarnations and you don't need it anyway other than to download the other two browsers. 

* [Google Chrome](https://www.google.com/chrome/)
* [Mozilla Firefox](https://www.mozilla.org/en-US/firefox/)

### Which Programming Languages

Different languages have different strengths. Every language is starting to get parity in features and code syntax as time goes by, but a programming language's strengths lies in its libraries. For the various languages, I'll use their respective version managers to install the latest versions of each language.

#### Node.js

For [Node.js](https://nodejs.org/en/), I will be using [Node Version Manager](https://github.com/creationix/nvm).

```bash
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="${XDG_CONFIG_HOME/:-$HOME/.}nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install node
```

#### Python
For [Python](https://www.python.org/downloads/), I will be using pyenv and its virtualenv plugin. 

```bash
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile
pyenv install-latest
pyenv install-latest 2.7
```

#### Java

If I want to mess around with different versions of Java, I'd do it in Docker containers, so no version managers for Java.

[Oracle JDK](https://www.oracle.com/technetwork/java/javase/downloads/index.html)

For reference, I'm going to put the `wget` command from this [Stack Overflow article](https://stackoverflow.com/questions/10268583/downloading-java-jdk-on-linux-via-wget-is-shown-license-page-instead), because it is useful in building Oracle JDK Docker containers and Ansible Scripts.

```bash

# Oracle JDK 11.0.1
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/11.0.1+13/90cf5d8f270a4347a95050320eef3fb7/jdk-11.0.1_linux-x64_bin.rpm
rpm -Uhv jdk-11.0.1_linux-x64_bin.rpm

# Oracle JDK 8u191
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.rpm
rpm -Uhv jdk-8u191-linux-x64.rpm

# JCE Unlimited Policy 
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip

```

If you need an older version of Oracle JDK, Oracle is doing everything it can to deny access to those older versions, in its attempt to shift everybody to a paid support model. That's a fine way to treat your developer base, I won't be surprised if Java fades into obscurity any time soon.  


#### Ruby

For [Ruby](https://www.ruby-lang.org/en/downloads/), I will be using [RVM](https://rvm.io).

```bash
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
rvm install ruby --latest
```



#### PHP

For [PHP](https://secure.php.net/downloads.php), I will be using [phpbrew](https://github.com/phpbrew/phpbrew).

```bash
curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew
chmod +x phpbrew

# Move phpbrew to somewhere can be found by your $PATH
sudo mv phpbrew /usr/local/bin/phpbrew
phpbrew init

cat <<-"EOF" | tee -a ~/.bashrc

[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc

EOF
```

#### Golang

For [Golang](https://golang.org/dl/), I will be using [gvm](https://github.com/moovweb/gvm).

```bash
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

gvm install go1.4 -B
gvm use go1.4
export GOROOT_BOOTSTRAP=$GOROOT
gvm install go1.5

```


### Docker

Docker has [useful documentation](https://docs.docker.com/install/linux/docker-ce/fedora/#install-docker-ce) on how to install Docker Community Edition on Fedora.

```bash
sudo dnf remove docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-selinux \
docker-engine-selinux \
docker-engine
                  
sudo dnf -y install dnf-plugins-core

sudo dnf config-manager \
--add-repo \
https://download.docker.com/linux/fedora/docker-ce.repo                  

sudo dnf install docker-ce
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker
```

### Ansible

Ansible can be [installed using Python pip](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-pip).

```bash
pip install ansible
```

### Other stuff

I use the Postman tool to test my APIs.

[Postman](https://www.getpostman.com/apps)

I've used VMWare Workstation and VirtualBox virtual networking with pfSense to do some complicated network setups.  

* [pfSense](https://www.pfsense.org/download/)

If I'm working with a Mac, first thing I'll do is to install Homebrew and use it to install as many of the above software as possible. Homebrew makes it really easy to install and keep up to date all the software packages, just like Yum or DNF.  
[Homebrew](https://brew.sh/)

There's a similar project for Fedora called Fedy. Apart from managing software, it also has useful tweaks for Fedora.
[Fedy](https://www.folkswithhats.org/)
