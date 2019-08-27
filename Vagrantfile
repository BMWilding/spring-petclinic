Vagrant.configure("2") do |config|

  config.vm.define 'jenkins', primary: true do |jenkins|
    jenkins.vm.box = 'liatrio-engineering/jenkins-nexus'
    jenkins.vm.hostname = 'liatrio-jenkins'
    jenkins.vm.network :private_network, type: 'dhcp'
    jenkins.vm.network :forwarded_port, guest: 8080, host: 16016

    jenkins.vm.provider :virtualbox do |vbox|
      vbox.gui = false  
      vbox.customize ['modifyvm', :id, '--cpus', 2] 
      vbox.customize ['modifyvm', :id, '--memory', 2048] 
    end

    jenkins.vm.provision :salt do |salt|
      salt.masterless = true
      salt.run_highstate = true
      salt.verbose = true 
      salt.python_version = '3'
      salt.minion_id = 'jenkins'
      salt.minion_config = 'salt/minion.yml'
      salt.pillar({
        'packages' => [
          'yum-plugin-versionlock'
        ],
        'jenkins' => {
          'url' => "http://localhost:8080",
          'password' => '',
          'master' => {
            'enabled' => false,
            'service' =>  'jenkins',
            'no_config' => true,
            'http' => {
              'port' => '8080'
            },
            'user' => {
              'admin' => {
                # The one, the only, the infamous!
                'username' => 'admin',
                'password' => 'admin'
              }
            },
            'plugins' => [
              { 'name' => 'docker-plugin' },
              { 'name' => 'blueocean' }, 
              { 'name' => 'durable-task' },
              { 'name' => 'docker-workflow' },
              { 'name' => 'pipeline-utility-steps' }
            ],
          },
          'client' => {
            'source' => { },
            'enabled' => true,
            'master' => {
              'host' => 'localhost',
              'port' => '8080',
              'protocol' => 'http'
            },
            'node' => {
              'worker' => {
                'remote_home' => '/home/jenkinsworker',
                'desc' => 'worker',
                'num_executors' => 2,
                'ret_strategy' => 'Always',
                'labels' => [ 
                  'docker'
                ],
                'launcher' => {
                   'type' => 'ssh',
                   'host' => '192.168.100.3',
                   'port' => 22,
                   'username' => 'jenkinsworker',
                   'password' => 'hardlyworking'
                }
              }
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
                    'spec' => "H/10 * * * *"
                  }
                }
              }
            }
          }
        },
        'serveo' => {
          'hostname' => 'liatriobryson'
        },
      })
    end

  end

  config.vm.define 'worker' do |worker|
    worker.vm.box = 'centos/7'
    worker.vm.hostname = "worker"
    worker.vm.network :private_network, ip: '192.168.100.3'
    worker.vm.network :forwarded_port, guest: 8081, host: 16017
    worker.vm.network :forwarded_port, guest: 9000, host: 16018

    worker.vm.provider :virtualbox do |vbox|
      vbox.gui = false  
      vbox.customize ['modifyvm', :id, '--cpus', 2] 
      vbox.customize ['modifyvm', :id, '--memory', 1538] 
    end

    worker.vm.provision :salt do |salt|
      salt.masterless = true
      salt.run_highstate = true
      salt.verbose = true
      salt.minion_id = 'worker'
      salt.python_version = '3'
      salt.minion_config = 'salt/minion.yml'
      salt.pillar({
        'packages' => [
          'yum-plugin-versionlock',
          'java-11-openjdk'
        ],
        'docker' => {
          'purge_abandoned' => true,
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
end
