Vagrant.configure("2") do |config|

  config.vm.define 'jenkins', primary: true do |jenkins|
    jenkins.vm.box = 'liatrio-engineering/jenkins-nexus'
    jenkins.vm.hostname = 'liatrio-jenkins'
    jenkins.vm.network :private_network, type: 'dhcp'
    jenkins.vm.network :forwarded_port, guest: 8080, host: 16016
    jenkins.vm.network :forwarded_port, guest: 8081, host: 16017
    jenkins.vm.network :forwarded_port, guest: 9000, host: 16018

    jenkins.vm.provider :virtualbox do |vbox|
      vbox.gui = false  
      vbox.customize ['modifyvm', :id, '--cpus', 4] 
      vbox.customize ['modifyvm', :id, '--memory', 4096] 
    end

    jenkins.vm.provision :shell, inline: "docker images | grep '<none>' | awk '{print $3;}' | xargs -I {} docker rmi {}"

    jenkins.vm.provision :salt do |salt|
      salt.masterless = true
      salt.run_highstate = true
      salt.verbose = true
      salt.minion_id = 'jenkins'
      salt.minion_config = 'salt/minion.yml'
      salt.pillar({
        'jenkins' => {
          'url' => "http://#{jenkins.vm.hostname}:8080",
          'user' => '',
          'password' => '',
          'client' => {
            'source' => { },
            'enabled' => true,
            'master' => {
              'host': 'localhost',
              'port': '8080',
              'protocol': 'http'
            },
            'lib' => { 
              'ldop-shared-library' => {
                'enabled' => true,
                'url' => 'https://github.com/liatrio/pipeline-library.git',
                'branch' => 'master'
              }
            },
            'job' => {
              'petclinic' => {
                'type' => 'workflow-scm',
                'displayname': 'petclinic',
                'concurrent' => false,
                'scm' => {
                  'type' => 'git',
                  'url' => 'https://github.com/BMWilding/spring-petclinic.git',
                  'branch' => 'hotfix/pipeline-issues',
                  'script' => 'Jenkinsfile',
                  'github' => {
                    'url' => 'https://github.com/BMWilding/spring-petclinic',
                    'name' => 'spring-petclinic'
                  }
                },
                'trigger' => {
                  'pollscm' => {
                    'spec' => "H/15 * * * *"
                  }
                }
              }
            }
          }
        }
      })
    end

    jenkins.vm.provision :shell, inline: <<-SCRIPT
    JENKINS_CLI='/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar'
    UPDATE_LIST='durable-task docker-plugin docker-workflow pipeline-utility-steps'
    echo Updating Jenkins Plugins: ${UPDATE_LIST}; 
    java -jar ${JENKINS_CLI} -s http://127.0.0.1:8080/ install-plugin ${UPDATE_LIST};
    java -jar ${JENKINS_CLI} -s http://127.0.0.1:8080/ safe-restart;
SCRIPT

  end

end
