## Detailed Deployment Steps

#### Jenkins Install Plugins

* Connect through the bastion and port forward back port 8080
* Log in using the admin user and the password you configured in the environment variables
* Choose either the install common or custom plugins options. The EC2 plugin has already been pre-installed

#### Jenkins Configure EC2 Plugin
* Add a new Ec2 Cloud
* Name will be the type of worker shown in the display (can have many)
* Check "Use EC2 instance profile to obtain credentials" as we have an instance role configured
* Region: Match the region you provisioned this environment
* In the Ec2 console create a Jenkins keypair, download and copy the private key into the keypair block

The remainder of the options allow you to set up multiple worker node configurations and tags which 
can then be used as targets in builds using the "Restrict where this project can be run" project build option. 
Unfortunately many of these options are hidden within "Advanced" configuration sections within the configuration 
screen. I've copied the plugin config from a section of the /var/lib/jenkins/config.xml file below.
 
The high level goals are as follows:

* You want to create some max number of worker nodes which can be of various sizes (ex: docker-large=m4.2xlarge, docker=t2.medium)
* On each worker node Jenkins provisions we'll install git and docker. Builds will happen within containers.
* Jenkins master node is provisioned in a private subnet so we'll want to check the options to connect via the internal IP

```
<clouds>
  <hudson.plugins.ec2.EC2Cloud plugin="ec2@1.36">
    <name>ec2-Docker Worker</name>
    <useInstanceProfileForCredentials>true</useInstanceProfileForCredentials>
    <credentialsId></credentialsId>
    <privateKey>YOUR_JENKINS_KEYPAIR</privateKey>
    <instanceCap>3</instanceCap>
    <templates>
      <hudson.plugins.ec2.SlaveTemplate>
        <ami>ami-b04e92d0</ami>
        <description>Amazon Linux</description>
        <zone>us-west-2a</zone>
        <securityGroups>internal-all</securityGroups>
        <remoteFS>/home/ec2-user</remoteFS>
        <type>T2Medium</type>
        <ebsOptimized>false</ebsOptimized>
        <labels>docker</labels>
        <mode>NORMAL</mode>
        <initScript>sudo yum update
sudo yum -y install docker git
sudo service docker start
sudo usermod -aG docker ec2-user
</initScript>
        <tmpDir></tmpDir>
        <userData></userData>
        <numExecutors>1</numExecutors>
        <remoteAdmin>ec2-user</remoteAdmin>
        <jvmopts></jvmopts>
        <subnetId>subnet-15070971</subnetId>
        <idleTerminationMinutes>30</idleTerminationMinutes>
        <iamInstanceProfile></iamInstanceProfile>
        <useEphemeralDevices>false</useEphemeralDevices>
        <customDeviceMapping></customDeviceMapping>
        <instanceCap>2147483647</instanceCap>
        <stopOnTerminate>false</stopOnTerminate>
        <tags>
          <hudson.plugins.ec2.EC2Tag>
            <name>Name</name>
            <value>jenkins-worker</value>
          </hudson.plugins.ec2.EC2Tag>
        </tags>
        <usePrivateDnsName>true</usePrivateDnsName>
        <associatePublicIp>false</associatePublicIp>
        <useDedicatedTenancy>false</useDedicatedTenancy>
        <amiType class="hudson.plugins.ec2.UnixData">
          <rootCommandPrefix></rootCommandPrefix>
          <sshPort>22</sshPort>
        </amiType>
        <launchTimeout>2147483647</launchTimeout>
        <connectBySSHProcess>true</connectBySSHProcess>
        <connectUsingPublicIp>false</connectUsingPublicIp>
      </hudson.plugins.ec2.SlaveTemplate>
    </templates>
    <region>us-west-2</region>
  </hudson.plugins.ec2.EC2Cloud>
</clouds>
```

#### Jenkins Configure Docker Build Job

* Check out the project source code using Git to Jenkins build workspace
* Build using a Docker container with the appropriate tools

#### Example Java Build Job

```
#!/bin/bash

# Run the maven package command using the official Maven Docker image
docker run --rm -v "$(pwd):/home/ec2-user" \
        maven:3-jdk-8 mvn -f /home/ec2-user package
```
