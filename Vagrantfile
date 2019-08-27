Vagrant.configure("2") do |config|

  primary_hostname    = 'liatrio-jenkins'
  primary_ip          = '192.168.100.2'
  dev_ip              = '192.168.100.3'
  serveo_subdomain    = 'liatriobryson'

  config.vm.define 'jenkins', primary: true do |jenkins|
    jenkins.vm.box = 'liatrio-engineering/jenkins-nexus'
    jenkins.vm.hostname = 'liatrio-jenkins'
    jenkins.vm.network :private_network, ip: primary_ip

    jenkins.vm.network :forwarded_port, guest: 8080, host: 6161
    jenkins.vm.network :forwarded_port, guest: 8081, host: 6162
    jenkins.vm.network :forwarded_port, guest: 9000, host: 6163 

    jenkins.vm.provider :virtualbox do |vbox|
      vbox.gui = false  
      vbox.customize ['modifyvm', :id, '--cpus', 2] 
      vbox.customize ['modifyvm', :id, '--memory', 2048] 
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
          'url' => "https://localhost:8080",
          'user' => '',
          'password' => '',
          'master' => {
            'no_config' => true,
            'plugins' => [
              'docker-plugin',
              'durable-task',
              'docker-workflow', 
              'pipeline-utility-steps'
            ]
          },
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
                  'branch' => 'master',
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
        },
        'docker' => {
          'network' => {
            'name' => 'liatrionet'
          }
        },
        'nexus' => {
          'remove_local' => true
        }
      })
    end

  end

  config.vm.define 'worker' do |worker|
    worker.vm.box = 'centos/7'
    worker.vm.hostname = "liatrio-dev"
    worker.vm.network :private_network, ip: dev_ip

    worker.vm.provider :virtualbox do |vbox|
      vbox.gui = false  
      vbox.customize ['modifyvm', :id, '--cpus', 2] 
      vbox.customize ['modifyvm', :id, '--memory', 1538] 
    end

    worker.vm.provision :salt do |salt|
      salt.masterless = true
      salt.run_highstate = true
      salt.verbose = true
      salt.minion_id = 'kubernetes-dev'
      salt.minion_config = 'salt/minion.yml'
      salt.pillar({
      })
    end
  end
end
