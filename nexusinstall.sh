#!/bin/bash
URL='http://download.sonatype.com/nexus/3/latest-unix.tar.gz'
user='nexus'

# Checking java instalation
if [ $(which java) ]
  then
    _java=$(java -version 2>&1| awk -F '"' '/version/ {print $2}')
    echo -e "\033[33m -Java version : $_java \033[0m"
  else
    sudo yum install -y java
fi

# Download Nexus
if [ -e /tmp/$(echo $URL | awk -F/ '{print $NF}') ]
 then
    echo -e "\033[33m -Archive is present \033[0m"
 else
    echo -e "\033[32m == Download Nexus == \033[0m"
    wget -P /tmp $URL && \
    echo -e "\033[32m == Download Nexus complited == \033[0m"
fi

#Unpack tar.gz
if [ -d /opt/nexus* ]
  then
    echo -e "\033[33m -Folder is present \033[0m"
  else
    echo "Unpacking archive"
    tar xzf /tmp/latest-unix.tar.gz -C /opt &&\
    echo -e "\033[032m -Unpacking complete \033[0m"
fi

#Create nexus user
nexus_folder=$(ls /opt | grep nexus)

grep "$user:" /etc/passwd > /dev/null
if [ $? -eq 0 ]
  then
    echo -e "\033[33m -User:\033[0;96m$user\033[0m\033[33m is present\033[0m"
  else
    useradd -c "Nexus User" $user 
    chown -R $user /opt/$nexus_folder /opt/sonatype* &&\
    echo -e "\033[32m -User: $user is created\033[0m"
fi

#start Nexus
PID=$(ps aux | grep "nexus" | awk ' /'usr'/ {print $2}')
if [[ $PID -eq " " ]]
  then
    sudo -u $user sh /opt/$nexus_folder/bin/nexus start
  else
    echo -e "\033[32m Nexus is started with PID=$PID\033[0m"
fi

