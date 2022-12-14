#!/usr/bin/env bash

check_user(){
    if [ "$EUID" -ne 0 ]
    then 
        echo "Current user is not a root"
    else
        echo "Current user is a root"
fi
}

change_ssh_port(){
    if [ "$EUID" -ne 0 ]
    then
        echo "Please run as a root"
    else 
        echo "Enter new ssh port: "
        read newPort
        sed -i "s/#port 22/port $newPort/g" /etc/ssh/sshd_config
        echo "SSH new port is $newPort "
    fi
}

disable_root_login(){
    if [ "$EUID" -ne 0 ]
    then
        echo "Please run as a root"
    else 
        sed -i "s/^PermitRootLogin yes$/PermitRootLogin no/g" /etc/ssh/sshd_config
    fi
}

add_new_user(){
    if [ "$EUID" -ne 0 ]
    then
        echo "Please run as a root"
    else 
        echo "Please enter username"
        read username
        useradd $username
        echo "Do you want to make this user a sudeor or not? y/n"
        read input
        if [ $input == "y" ]
        then
            echo "$username ALL =(ALL) ALL " >> /etc/sudores
        fi
    fi
}

add_backup(){
    touch ~/backup.txt
    echo " * * * * * tar cvf /home/backup/home_backup.tar /home/$USER/* " > ~/backup.txt
	crontab ~/backup.txt
}

check_user

change_ssh_port

disable_root_login

add_new_user

add_backup