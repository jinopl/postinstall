#!/bin/bash
#if ubuntu run this else run that
if [[ $EUID -ne 0 ]]; then
 echo "This script must be run as root" 
 exit 1
fi

lsb_dist="$(. /etc/os-release && echo "$ID")"

function deb(){

	 echo "Updating and Upgrading"
 	 apt-get update && sudo apt-get upgrade -y
 	 sudo apt-get install dialog
 	 cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
	 options=(1 "Sublime Text 3" off # any option can be set to default to "on"
	 2 "LAMP Stack" off
	 3 "Build Essentials" off
	 4 "Node.js" off
	 5 "Ubuntu Restricted Extras" off)
	 choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	 clear
	 for choice in $choices
	 do
	 case $choice in
	 	1)
			echo " Install Sublime 3"
			wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
			sudo apt-get install apt-transport-https -y
			echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
			apt-get update
			apt-get install sublime-text
	 		;;
	 	2)
			echo "Installing Lamp stack"
			
			echo "Installing Apache"
			apt install apache2 -y
			systemctl start apache2
			systemctl enable apache2


			echo "Installing Mysql Server"
			apt install mysql-server -y
			systemctl enable mysqld

			echo "Installing PHP"
			apt install php libapache2-mod-php php-mcrypt php-mysql -y
			 
			echo "Installing Phpmyadmin"
			apt install phpmyadmin -y

			echo "Cofiguring apache to run Phpmyadmin"
			echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
			 
			echo "Restarting Apache Server"
			service apache2 restart
			;;
		3)
			echo "Build Essentials"
			apt install -y build-essential
			;;
		
		4)
			echo "Installing Nodejs Lts "
			sudo apt-get install curl
			curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
			;;
		5)
			echo "Ubuntu Restricted extras"
			sudo apt-get install ubuntu-restricted-extras

	 esac
	 exit 1
done
}

function rpm(){

	echo "Updating and Upgrading"
 	 sudo yum update && sudo yum upgrade -y
 	 sudo yum install dialog
 	 cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
	 options=(1 "Sublime Text 3" off # any option can be set to default to "on"
	 2 "LAMP Stack" off
	 3 "Build Essentials" off
	 4 "Node.js" off)
	 choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	 clear
	 for choice in $choices
	 do
	 case $choice in
	 	1)
			echo " Install Sublime 3"
			sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
			sudo yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
			echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
			yum update
			sudo yum install sublime-text
	 		;;
	 	2)
			echo "Installing Lamp stack"
			
			echo "Installing httpd"
			sudo yum install httpd -y
			systemctl start httpd
			systemctl enable httpd


			echo "Installing Mysql Server"
			yum localinstall https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
			yum install mysql-community-server
			systemctl start mysqld.service
			systemctl enable mysqld.service

			echo "Installing PHP"
			sudo yum install epel-release -y 
			sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
			sudo yum install yum-utils -y
			sudo yum-config-manager --enable remi-php72
			sudo yum update
			sudo yum install php libapache2-mod-php php-mcrypt php-mysql -y
			 
			echo "Installing Phpmyadmin"
			sudo yum install phpmyadmin -y

			echo "Restarting httpd"
			systemctl restart httpd
			;;
		3)
			echo "Build Essentials"
			sudo yum -y install gcc gcc-c++ kernel-devel make
			;;
		
		4)
			echo "Installing Nodejs Lts "
			sudo yum install curl
			curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
			;;
	 esac
	 exit 1
done
}

case $lsb_dist in
	ubuntu|debian|raspbian )
		deb
		;;
	centos|fedora )
		rpm
		;;
	*)
			echo
			echo "ERROR: Unsupported distribution '$lsb_dist'"
			echo
			exit 1
esac
