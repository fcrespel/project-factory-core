pipeline {
  agent { label 'docker' }
  parameters {
    string(name: 'product_groupId', defaultValue: 'fr.project-factory.core.products', description: 'Product groupId')
    string(name: 'product_artifactId', defaultValue: 'default', description: 'Product artifactId')
    string(name: 'product_version', defaultValue: '3.4.0', description: 'Product version')
    string(name: 'product_file', defaultValue: 'product-dev.properties', description: 'Product file')
    string(name: 'maven_opts', defaultValue: '', description: 'Maven environment options')
    string(name: 'maven_cli_opts', defaultValue: '-U -B -s .mvn/settings.xml', description: 'Maven CLI options')
    string(name: 'maven_goals', defaultValue: 'clean install', description: 'Maven build goals')
    string(name: 'maven_repo_creds', defaultValue: 'project-factory-maven-repo-creds', description: 'Maven distribution repository credentials')
    string(name: 'docker_repo', defaultValue: 'projectfactory', description: 'Docker build image repository')
    string(name: 'docker_image', defaultValue: 'build', description: 'Docker build image name')
    string(name: 'docker_opts', defaultValue: '', description: 'Docker build image run options')
    string(name: 'package_repo_url', defaultValue: 'https://services.crespel.me/nexus/repository', description: 'Package repository base URL')
    string(name: 'package_repo_centos7', defaultValue: 'project-factory-releases-centos7', description: 'Package repository for CentOS 7')
    string(name: 'package_repo_debian9', defaultValue: 'project-factory-releases-debian9', description: 'Package repository for Debian 9')
    string(name: 'package_repo_opensuse423', defaultValue: 'project-factory-releases-opensuse423', description: 'Package repository for openSUSE 42.3')
    string(name: 'package_repo_ubuntu1604', defaultValue: 'project-factory-releases-ubuntu1604', description: 'Package repository for Ubuntu 16.04')
    string(name: 'package_repo_creds', defaultValue: 'project-factory-package-repo-creds', description: 'Package repository credentials')
    booleanParam(name: 'build_centos7', defaultValue: true, description: 'Build packages for CentOS 7')
    booleanParam(name: 'build_debian9', defaultValue: true, description: 'Build packages for Debian 9')
    booleanParam(name: 'build_opensuse423', defaultValue: true, description: 'Build packages for openSUSE 42.3')
    booleanParam(name: 'build_ubuntu1604', defaultValue: true, description: 'Build packages for Ubuntu 16.04')
    booleanParam(name: 'publish_centos7', defaultValue: false, description: 'Publish packages for CentOS 7')
    booleanParam(name: 'publish_debian9', defaultValue: false, description: 'Publish packages for Debian 9')
    booleanParam(name: 'publish_opensuse423', defaultValue: false, description: 'Publish packages for openSUSE 42.3')
    booleanParam(name: 'publish_ubuntu1604', defaultValue: false, description: 'Publish packages for Ubuntu 16.04')
  }
  environment {
    MAVEN_OPTS = "${params.maven_opts}"
    MAVEN_REPO_CREDS = credentials("${params.maven_repo_creds}")
    PACKAGE_REPO_CREDS = credentials("${params.package_repo_creds}")
  }
  stages {
    stage('Build Parent') {
      steps {
        sh "./mvnw -N ${params.maven_cli_opts} ${params.maven_goals}"
      }
    }
    stage('Build Modules') {
      parallel {
        stage('Archetypes') {
          steps {
            sh "./mvnw -f archetypes/pom.xml ${params.maven_cli_opts} ${params.maven_goals}"
          }
        }
        stage('Plugins') {
          steps {
            sh "./mvnw -f plugins/pom.xml ${params.maven_cli_opts} ${params.maven_goals}"
          }
        }
        stage('Products') {
          steps {
            sh "./mvnw -f products/pom.xml ${params.maven_cli_opts} ${params.maven_goals}"
          }
        }
        stage('Resources') {
          steps {
            sh "./mvnw -f resources/pom.xml ${params.maven_cli_opts} ${params.maven_goals}"
          }
        }
      }
    }
    stage('Build Packages') {
      parallel {
        stage('CentOS 7') {
          agent {
            docker {
              image "${params.docker_repo}/${params.docker_image}:centos7"
              args "-v \$HOME/.m2:/var/maven/.m2 -v \$HOME/.m2/repository:/var/maven/.m2/repository -v \$HOME/.gnupg:/var/maven/.gnupg ${params.docker_opts}"
            }
          }
          when {
            beforeAgent true
            expression { params.build_centos7 == true }
          }
          stages {
            stage('CentOS 7 Build') {
              steps {
                sh "/bin/bash -l -c './mvnw -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.maven_cli_opts} ${params.maven_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-el7-x86_64.properties -P !deb'"
              }
            }
            stage('CentOS 7 Publish') {
              when {
                expression { params.publish_centos7 == true }
              }
              steps {
                sh "find . -wholename '*/target/*.rpm' -print0 | xargs -0 -n1 curl -u '${PACKAGE_REPO_CREDS_USR}:${PACKAGE_REPO_CREDS_PSW}' '${params.package_repo_url}/${params.package_repo_centos7}/' -T"
              }
            }
          }
        }
        stage('Debian 9') {
          agent {
            docker {
              image "${params.docker_repo}/${params.docker_image}:debian9"
              args "-v \$HOME/.m2:/var/maven/.m2 -v \$HOME/.m2/repository:/var/maven/.m2/repository -v \$HOME/.gnupg:/var/maven/.gnupg ${params.docker_opts}"
            }
          }
          when {
            beforeAgent true
            expression { params.build_debian9 == true }
          }
          stages {
            stage('Debian 9 Build') {
              steps {
                sh "/bin/bash -l -c './mvnw -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.maven_cli_opts} ${params.maven_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-debian9-amd64.properties -P !rpm'"
              }
            }
            stage('Debian 9 Publish') {
              when {
                expression { params.publish_debian9 == true }
              }
              steps {
                sh "find . -wholename '*/target/*.deb' -printf '@%p\0' | xargs -0 -n1 curl -H 'Content-Type: multipart/form-data' -u '${PACKAGE_REPO_CREDS_USR}:${PACKAGE_REPO_CREDS_PSW}' '${params.package_repo_url}/${params.package_repo_debian9}/' --data-binary"
              }
            }
          }
        }
        stage('openSUSE 42.3') {
          agent {
            docker {
              image "${params.docker_repo}/${params.docker_image}:opensuse423"
              args "-v \$HOME/.m2:/var/maven/.m2 -v \$HOME/.m2/repository:/var/maven/.m2/repository -v \$HOME/.gnupg:/var/maven/.gnupg ${params.docker_opts}"
            }
          }
          when {
            beforeAgent true
            expression { params.build_opensuse423 == true }
          }
          stages {
            stage('openSUSE 42.3 Build') {
              steps {
                sh "/bin/bash -l -c './mvnw -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.maven_cli_opts} ${params.maven_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-opensuse423-x86_64.properties -P !deb'"
              }
            }
            stage('openSUSE 42.3 Publish') {
              when {
                expression { params.publish_opensuse423 == true }
              }
              steps {
                sh "find . -wholename '*/target/*.rpm' -print0 | xargs -0 -n1 curl -u '${PACKAGE_REPO_CREDS_USR}:${PACKAGE_REPO_CREDS_PSW}' '${params.package_repo_url}/${params.package_repo_opensuse423}/' -T"
              }
            }
          }
        }
        stage('Ubuntu 16.04') {
          agent {
            docker {
              image "${params.docker_repo}/${params.docker_image}:ubuntu1604"
              args "-v \$HOME/.m2:/var/maven/.m2 -v \$HOME/.m2/repository:/var/maven/.m2/repository -v \$HOME/.gnupg:/var/maven/.gnupg ${params.docker_opts}"
            }
          }
          when {
            beforeAgent true
            expression { params.build_ubuntu1604 == true }
          }
          stages {
            stage('Ubuntu 16.04 Build') {
              steps {
                sh "/bin/bash -l -c './mvnw -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.maven_cli_opts} ${params.maven_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-ubuntu1604-amd64.properties -P !rpm'"
              }
            }
            stage('Ubuntu 16.04 Publish') {
              when {
                expression { params.publish_ubuntu1604 == true }
              }
              steps {
                sh "find . -wholename '*/target/*.deb' -printf '@%p\0' | xargs -0 -n1 curl -H 'Content-Type: multipart/form-data' -u '${PACKAGE_REPO_CREDS_USR}:${PACKAGE_REPO_CREDS_PSW}' '${params.package_repo_url}/${params.package_repo_ubuntu1604}/' --data-binary"
              }
            }
          }
        }
      }
    }
  }
}
