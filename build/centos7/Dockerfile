# Build image for CentOS 7
FROM centos:7
MAINTAINER Fabien Crespel <fabien@crespel.net>

# Arguments
ARG MVN_VERSION=3.5.3
ARG MVN_URL=https://archive.apache.org/dist/maven/maven-3/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz
ARG RUBY_VERSION=2.4.5

# Configure repositories
RUN yum -y install yum-utils https://rpms.remirepo.net/enterprise/remi-release-7.rpm && yum-config-manager --enable remi-php70 && yum -y clean all

# Install packages
RUN yum -y update && yum -y clean all
RUN yum -y install which initscripts && yum -y clean all
RUN yum -y install git subversion java-1.8.0-openjdk-devel && yum -y clean all
RUN yum -y install rpm-build rpm-sign gcc gcc-c++ make cmake php php-mbstring php-pdo php-pear php-xml python python-setuptools expect && yum -y clean all

# Install Maven
RUN mkdir -p /usr/share/maven /var/maven/build &&\
	curl -fsSL -o /tmp/apache-maven.tar.gz ${MVN_URL} &&\
	tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 &&\
	rm -f /tmp/apache-maven.tar.gz &&\
	ln -s /usr/share/maven/bin/mvn /usr/bin/mvn &&\
	chmod -R 777 /var/maven

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB &&\
	curl -sSL https://get.rvm.io | bash -s stable &&\
	/usr/local/rvm/bin/rvm requirements &&\
	/usr/local/rvm/bin/rvm install ${RUBY_VERSION} --rubygems ignore &&\
	/usr/local/rvm/bin/rvm alias create default ${RUBY_VERSION} &&\
	/usr/local/rvm/bin/rvm default do gem install bundler --no-ri --no-rdoc &&\
	/usr/local/rvm/bin/rvm cleanup all &&\
	yum -y clean all

CMD ["/bin/bash", "-l"]
