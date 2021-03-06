# Build image for openSUSE 42.3
FROM opensuse:42.3
MAINTAINER Fabien Crespel <fabien@crespel.net>

# Arguments
ARG MVN_VERSION=3.5.4
ARG MVN_URL=https://archive.apache.org/dist/maven/maven-3/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz
ARG RUBY_VERSION=2.4.6
ARG BUNDLER_VERSION=1.17.3

# Install packages
RUN zypper patch -y --with-optional; zypper patch -y --with-optional; zypper clean -a
RUN zypper in -y which curl &&\
	zypper in -y git subversion java-1_8_0-openjdk-devel &&\
	zypper in -y rpm-build gcc gcc-c++ make cmake php7 php7-curl php7-fileinfo php7-iconv php7-json php7-mbstring php7-openssl php7-pdo php7-pear php7-phar php7-tokenizer php7-xmlreader php7-xmlwriter php7-xsl php7-zip php7-zlib python python-setuptools expect &&\
	zypper clean -a

# Install Maven
RUN mkdir -p /usr/share/maven /var/maven/build &&\
	curl -fsSL -o /tmp/apache-maven.tar.gz ${MVN_URL} &&\
	tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 &&\
	rm -f /tmp/apache-maven.tar.gz &&\
	ln -s /usr/share/maven/bin/mvn /usr/bin/mvn &&\
	chmod -R 777 /var/maven

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB &&\
	curl -sSL https://get.rvm.io | bash -s stable --without-gems="bundler" &&\
	/usr/local/rvm/bin/rvm requirements &&\
	/usr/local/rvm/bin/rvm install ${RUBY_VERSION} --rubygems ignore &&\
	/usr/local/rvm/bin/rvm alias create default ${RUBY_VERSION} &&\
	/usr/local/rvm/bin/rvm default do gem install bundler:${BUNDLER_VERSION} --no-document &&\
	/usr/local/rvm/bin/rvm cleanup all &&\
	zypper clean -a

CMD ["/bin/bash", "-l"]
