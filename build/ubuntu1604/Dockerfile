# Build image for Ubuntu 16.04
FROM ubuntu:16.04
MAINTAINER Fabien Crespel <fabien@crespel.net>

# Arguments
ARG MVN_VERSION=3.5.3
ARG MVN_URL=https://archive.apache.org/dist/maven/maven-3/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz
ARG RUBY_VERSION=2.4.5
ARG BUNDLER_VERSION=1.17.3

# Install initial packages
RUN apt-get -q update &&\
	DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
	DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends curl dirmngr gnupg locales &&\
	apt-get -q autoremove &&\
	apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Configure locale
RUN sed -i 's|# en_US\.UTF-8 UTF-8|en_US.UTF-8 UTF-8|g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install additional packages
RUN apt-get -q update &&\
	DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends git subversion openjdk-8-jdk &&\
	apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin
RUN apt-get -q update &&\
	DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends build-essential cmake php php-curl php-mbstring php-xml php-pear python python-setuptools &&\
	apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

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
	/usr/local/rvm/bin/rvm install ${RUBY_VERSION} --rubygems ignore --skip-gemsets &&\
	/usr/local/rvm/bin/rvm alias create default ${RUBY_VERSION} &&\
	/usr/local/rvm/bin/rvm default do gem install bundler:${BUNDLER_VERSION} --no-ri --no-rdoc &&\
	/usr/local/rvm/bin/rvm cleanup all &&\
	apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

CMD ["/bin/bash", "-l"]
