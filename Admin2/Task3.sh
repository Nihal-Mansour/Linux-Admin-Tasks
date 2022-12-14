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

add_new_group(){
    groupadd -g 20000 Audit
    echo "Group Audit is added successfully with id 20000"
}

add_new_user(){
    if [ $(id -u) -eq 0 ]
    then
	    read -p "Please enter username : " username
	    read -s -p "Please enter password : " password
	    egrep "^$username" /etc/passwd >/dev/null
	    if [ $? -eq 0 ]
        then
		    echo "$username exists!"
	    else
		    pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		    useradd -m -p "$pass" "$username"
		    [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	    fi
    else
	    echo "Only root may add a user to the system."
    fi 
}

#function to get number of days according to the given month
getMonthDays () {
    if [ $1 -eq 2 ]
    then
        duration=28
    fi
    case $1 in
    4|6|9) duration=30 ;;
    esac
    case $1 in
    1|3|5|7|8|10|12) duration=31 ;;
    esac
}

create_reports(){
    mkdir /home/$USER/reports
    for i in {1..12}
    do
        getMonthDays "$i"
        for j in $(seq 1 $duration)
        do
            touch /home/$USER/reports/2021-$i-$j.xls
        done
    done
    echo "reports folder created successfully ..."
}

set_permissions(){
    chmod -R 660 /home/$USER/reports/*
    echo "reports folder permisions changed successfully ..."
}

update_upgrade_system(){
    yum update -y
    echo "system update is done ..."
    yum upgrade -y
    echo "system upgrade is done ..."
}

enable_epel(){
	yum install "epel-release"
    echo "epel is installed successfully ..."
}

install_fail2ban(){
    yum install fail2ban -y
	sudo systemctl enable fail2ban
    sudo systemctl start fail2ban	
    echo "fail2ban is installed successfully ..."
}

add_cron_job(){
    mkdir ~/backups
	echo "00 1 * * 1-4 tar -czf ~/backups/reports-$(date +%U)-$(date +%d).tar.gz /home/$USER/reports" > " ~/backup.txt"
	crontab "~/backup.txt"
}

add_new_manager(){
    useradd -u 30000 manager
    if [ $? -eq 0 ]
    then
	    echo "New manager is added successfully ..."
    else
	    echo "Error occurs"
    fi
}

sync_reports(){
    mkdir /home/$USER/manager
    mkdir /home/$USER/manager/audit
	mkdir /home/$USER/manager/audit/reports
	echo "00 2 * * 1-4 sync /home/$USER/reports /home/$USER/manager/audit/reports" > "/tmp/sync.txt"
    crontab "/tmp/sync.txt"
}


check_user
change_ssh_port
disable_root_login
add_new_group
add_new_user
create_reports
set_permissions
update_upgrade_system
enable_epel
install_fail2ban
add_cron_job
add_new_manager
sync_reports
