Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"
    config.vm.box_version = "2004.01"

    # Console VM
    config.vm.define "console" do |console|
        console.vm.provider "virtualbox" do |v|
            v.name = "console"
            v.memory = 16384 
            v.cpus = 4 
        end
        console.disksize.size = "150GB"
        console.vm.hostname = "console.sb"
        # Change the bridge interface and IP Address as per your set-up
        console.vm.network "public_network", bridge: "eno2", ip: "172.29.108.11", hostname: true
        
        # Default Router: This enables the vagrant VMs to be reached over the network
        console.vm.provision "shell",
            run: "always",
            inline: "sudo yum install net-tools -y"
        console.vm.provision "shell",
            run: "always",
            inline: "route add default gw 172.29.108.1"
        console.vm.provision "shell",
            run: "always",
            inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"
        
        # SSH Key Exchange
        console.vm.provision "shell", run: "always", inline: "mkdir -p /root/.ssh"
        console.vm.provision "file", run: "always", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
        console.vm.provision "file", run: "always", source: "~/.ssh/id_rsa", destination: "~/.ssh/id_rsa"
        console.vm.provision "shell", run: "always", inline: <<-SHELL
            cat ~vagrant/.ssh/id_rsa.pub >> ~vagrant/.ssh/authorized_keys
            cat ~vagrant/.ssh/id_rsa.pub >> ~root/.ssh/authorized_keys
        SHELL
    end

    #MZ Cluster
    config.vm.define "mzmaster" do |mzmaster|
        #mzmaster.vm.box = "mzmaster.sb"
        mzmaster.vm.provider "virtualbox" do |v|
            v.name = "mzmaster"
            v.memory = 8192 
            v.cpus = 4 
        end
        mzmaster.disksize.size = "60GB"
        mzmaster.vm.hostname = "mzmaster.sb"
        # Change the bridge interface and IP Address as per your set-up
        mzmaster.vm.network "public_network", bridge: "eno2", ip: "172.29.108.12", hostname: true

        # Default Router: This enables the vagrant VMs to be reached over the network
        mzmaster.vm.provision "shell",
            run: "always",
            inline: "sudo yum install net-tools -y"
        mzmaster.vm.provision "shell",
            run: "always",
            inline: "route add default gw 172.29.108.1"
        mzmaster.vm.provision "shell",
            run: "always",
            inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"

        #SSH Key Exchange
        mzmaster.vm.provision "shell", run: "always", inline: "mkdir -p /root/.ssh"
        mzmaster.vm.provision "file", run: "always", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
        mzmaster.vm.provision "shell", run: "always", inline: <<-SHELL
            cat ~vagrant/.ssh/id_rsa.pub >> ~vagrant/.ssh/authorized_keys
            cat ~vagrant/.ssh/id_rsa.pub >> ~root/.ssh/authorized_keys
        SHELL
    end

    (0..4).each do |i|
        config.vm.define "mzworker#{i}" do |mzworker|
            #mzworker.vm.box = "mzworker#{i}.sb"
            mzworker.vm.provider "virtualbox" do |v|
                v.name = "mzworker#{i}"
                v.memory = 15360 
                v.cpus = 4 
            end
            #mzworker.vm.disk :disk, size: "60GB", primary: true
            mzworker.disksize.size = "60GB"
            mzworker.vm.hostname = "mzworker#{i}.sb"
            # Change the bridge interface and IP Address as per your set-up
            mzworker.vm.network "public_network", bridge: "eno2", ip: "172.29.108.#{i+13}", hostname: true

            # Default router: This enables the vagrant VMs to be reached over the network
            mzworker.vm.provision "shell",
                run: "always",
                inline: "sudo yum install net-tools -y"
            mzworker.vm.provision "shell",
                run: "always",
                inline: "route add default gw 172.29.108.1"
            mzworker.vm.provision "shell",
                run: "always",
                inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"

            # SSH Key Exchange
            mzworker.vm.provision "shell", run: "always", inline: "mkdir -p /root/.ssh"
            mzworker.vm.provision "file", run: "always", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
            mzworker.vm.provision "shell", run: "always", inline: <<-SHELL
                cat ~vagrant/.ssh/id_rsa.pub >> ~vagrant/.ssh/authorized_keys
                cat ~vagrant/.ssh/id_rsa.pub >> ~root/.ssh/authorized_keys
            SHELL
        end
    end

    
    # DMZ Cluster

    config.vm.define "dmzmaster" do |dmzmaster|
        #dmzmaster.vm.box = "dmzmaster.sb"
        dmzmaster.vm.provider "virtualbox" do |v|
            v.name = "dmzmaster"
            v.memory = 8192 
            v.cpus = 4 
        end
        #dmzmaster.vm.disk :disk, size: "60GB", primary: true
        dmzmaster.disksize.size = "60GB"
        dmzmaster.vm.hostname = "dmzmaster.sb"
        # Change the bridge interface and IP Address as per your set-up
        dmzmaster.vm.network "public_network", bridge: "eno2", ip: "172.29.108.18", hostname: true

        # Default Router: This enables the vagrant VMs to be reached over the network
        dmzmaster.vm.provision "shell",
            run: "always",
            inline: "sudo yum install net-tools -y"
        dmzmaster.vm.provision "shell",
            run: "always",
            inline: "route add default gw 172.29.108.1"
        dmzmaster.vm.provision "shell",
            run: "always",
            inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"
        
        # SSH Keys Exchange
        dmzmaster.vm.provision "shell", run: "always", inline: "mkdir -p /root/.ssh"
        dmzmaster.vm.provision "file", run: "always", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
        dmzmaster.vm.provision "shell", run: "always", inline: <<-SHELL
            cat ~vagrant/.ssh/id_rsa.pub >> ~vagrant/.ssh/authorized_keys
            cat ~vagrant/.ssh/id_rsa.pub >> ~root/.ssh/authorized_keys
        SHELL
    end

    config.vm.define "dmzworker0" do |dmzworker0|
        #dmzworker0.vm.box = "dmzworker0.sb"
        dmzworker0.vm.provider "virtualbox" do |v|
            v.name = "dmzworker0"
            v.memory = 15360 
            v.cpus = 4 
        end
        #dmzworker0.vm.disk :disk, size: "60GB", primary: true
        dmzworker0.disksize.size = "60GB"
        dmzworker0.vm.hostname = "dmzworker0.sb"
        # Change the bridge interface and IP Address as per your set-up
        dmzworker0.vm.network "public_network", bridge: "eno2", ip: "172.29.108.19", hostname: true
        # Default router: This enables the vagrant VMs to be reached over the network
        dmzworker0.vm.provision "shell",
            run: "always",
            inline: "sudo yum install net-tools -y"
        dmzworker0.vm.provision "shell",
            run: "always",
            inline: "route add default gw 172.29.108.1"
        dmzworker0.vm.provision "shell",
            run: "always",
            inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"
        
        # SSH Keys Exchange
        dmzworker0.vm.provision "shell", run: "always", inline: "mkdir -p /root/.ssh"
        dmzworker0.vm.provision "file", run: "always", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
        dmzworker0.vm.provision "shell", run: "always", inline: <<-SHELL
            cat ~vagrant/.ssh/id_rsa.pub >> ~vagrant/.ssh/authorized_keys
            cat ~vagrant/.ssh/id_rsa.pub >> ~root/.ssh/authorized_keys
        SHELL
    end
  end