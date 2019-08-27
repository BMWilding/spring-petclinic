#!/bin/env groovy

@Library('ldop-shared-library') _

pipeline {
  agent none

  environment {
    IMAGE = "liatrio/petclinic-tomcat"
    LDOP_NETWORK_NAME = "bridge"
    INITIAL_ADMIN_USER = 'admin'
    INITIAL_ADMIN_PASSWORD = 'admin123'    
    SONAR_ACCOUNT_LOGIN = 'admin'
    SONAR_ACCOUNT_PASSWORD = 'admin'

    // No need to deploy a fake app to DockerHub
    IS_REAL = false
  }

  stages {

    stage('Build') {
      agent {
        docker {
          image 'maven:3.5.0'
          args '-e INITIAL_ADMIN_USER -e INITIAL_ADMIN_PASSWORD --network=${LDOP_NETWORK_NAME}'
        }
      }
      steps {
        configFileProvider([configFile(fileId: 'nexus', variable: 'MAVEN_SETTINGS')]) {
          sh 'mvn -s $MAVEN_SETTINGS clean deploy -DskipTests=true -B'
        }
      }
    }
    stage('Sonar') {
      agent  {
        docker {
          image 'ciricihq/gitlab-sonar-scanner'
          args '-e SONAR_ACCOUNT_LOGIN -e SONAR_ACCOUNT_PASSWORD --network=${LDOP_NETWORK_NAME}'
        }
      }
      steps {
        sh 'sonar-scanner -X -D sonar.login=${SONAR_ACCOUNT_LOGIN} -D sonar.password=${SONAR_ACCOUNT_PASSWORD} -Dsonar.projectBaseDir=${PWD}'
      }
    }

    stage('Get Artifact') {
      agent {
        docker {
          image 'maven:3.5.0'
          args '-e INITIAL_ADMIN_USER -e INITIAL_ADMIN_PASSWORD --network=${LDOP_NETWORK_NAME}'
        }
      }
      steps {
        sh 'mvn clean'
        script {
          pom = readMavenPom file: 'pom.xml'
          getArtifact(pom.groupId, pom.artifactId, pom.version, 'petclinic')
        }
      }
    }

    stage('Build container') {
      agent any
      steps {
        script {
          if ( env.BRANCH_NAME == 'master' ) {
            pom = readMavenPom file: 'pom.xml'
            TAG = pom.version
          } else {
            TAG = env.BRANCH_NAME
          }
          sh "docker build -t ${env.IMAGE}:${TAG} ."
        }
      }
    }

    stage('Run local container') {
      agent any
      steps {
        sh 'docker rm -f petclinic-tomcat-temp || true'
        sh "docker run -d --network=${LDOP_NETWORK_NAME} --name petclinic-tomcat-temp ${env.IMAGE}:${TAG}"
      }
    }

    stage('Smoke-Test & OWASP Security Scan') {
      when {
        expression { IS_REAL == true }
      }
      agent {
        docker {
          image 'maven:3.5.0'
          args '--network=${LDOP_NETWORK_NAME}'
        }
      }
      steps {
        sh "cd regression-suite && mvn clean -B test -DPETCLINIC_URL=http://petclinic-tomcat-temp:8080/petclinic/"
      }
    }
    stage('Stop local container') {
      agent any
      steps {
        sh 'docker rm -f petclinic-tomcat-temp || true'
      }
    }


    stage('Push to dockerhub') {
      when {
        expression { IS_REAL == true }
      }
      agent any
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerPassword', usernameVariable: 'dockerUsername')]){
          script {
            sh "docker login -u ${env.dockerUsername} -p ${env.dockerPassword}"
            sh "docker push ${env.IMAGE}:${TAG}"
          }
        }
      }
    }
    
    stage('Deploy to dev') {
      when {
        branch 'master'
      }
      agent any
      steps {
        script {
          deployToEnvironment("ec2-user", "dev.petclinic.liatr.io", "petclinic-deploy-key", env.IMAGE, TAG, "spring-petclinic", "dev.petclinic.liatr.io")
        }
      }
    }
    
    stage('Smoke test dev') {
      when {
        branch 'master'
      }
      agent {
        docker {
          image 'maven:3.5.0'
          args '--network=${LDOP_NETWORK_NAME}'
        }
      }
      steps {
        sh "cd regression-suite && mvn clean -B test -DPETCLINIC_URL=https://dev.petclinic.liatr.io/petclinic"
        echo "Should be accessible at https://dev.petclinic.liatr.io/petclinic"
      }
    }

    stage('Deploy to Staging') {
      when {
        branch 'master'
      }
      agent {
        docker {
          image 'maven:3.5.0'
          args '-e JOB_NAME --network=${LDOP_NETWORK_NAME}'
        }
      }
      steps {
        sh "echo deploying ${JOB_NAME} to staging..."
        echo "Deployed!"
      }
    }
  }
}
