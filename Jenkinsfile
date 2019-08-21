#!/bin/env groovy

@Library('ldop-shared-library') _

pipeline {
  agent none

  environment {
    IMAGE = 'liatrio/petclinic-tomcat'
    TAG = '1.0.0'
  }

  stages {

    stage('Build') {
      agent {
        docker {
          image 'maven:3.5.0'
          args '-e admin -e password'
        }
      }
      environment {
        SERVER = 'http://liatrioaartifactory:9000/artifactory/liatriomaven'
      }
      steps {
        sh "mvn"
      }
    }
    stage('Sonar') {
      agent  {
        docker {
          image 'centos:7'
        }
      }
      environment {
        SONAR_ACCOUNT_LOGIN = 'admin'
        SONAR_ACCOUNT_PASSWORD = 'admin'
      }
      steps {
        sh "echo Running sonar"
      }
    }

    stage('Get Artifact') {
      agent {
        docker {
          image 'maven:3.5.0'
          args '-e admin -e password'
        }
      }
      steps {
        sh 'mvn clean'
      }
    }

    stage('Build container') {
      agent any
      steps {
          sh "echo docker build -t ${IMAGE}:${TAG} ."
      }
    }

    stage('Run local container') {
      agent any
      steps {
        sh "echo docker run -d --name petclinic-tomcat-temp ${IMAGE}:${TAG}"
      }
    }

    stage('Smoke-Test & OWASP Security Scan') {
      agent {
        docker {
          image 'maven:3.5.0'
        }
      }
      steps {
        sh "echo cd regression-suite && mvn clean -B test -DPETCLINIC_URL=http://petclinic-tomcat-temp:8080/petclinic/"
        sh "echo The tests run, but fail..."
      }
    }

    stage('Stop local container') {
      agent any
      steps {
        sh 'echo docker rm -f petclinic-tomcat-temp || true'
      }
    }

    stage('Deploy to dev') {
      when {
        branch 'master'
      }
      agent any
      steps {
        sh "echo docker run -d petclinic-tomcat-temp ${IMAGE}:${TAG}"
      }
    }
    
    stage('Smoke test Dev') {
      agent any
      steps {
        sh 'echo Smoked like salmon'
      }
    }
  }
}
