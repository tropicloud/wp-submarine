
# CHECK
# ---------------------------------------------------------------------------------

wps_check() {
	if [[  -d $www  ]];
	then /bin/true
	else wps_setup
	fi
}


# HEADER
# ---------------------------------------------------------------------------------

wps_header() {
	echo -e "\033[0;30m
-----------------------------------------------------
\033[1;34m  (wp)\033[1;37mSubmarine\033[0m - $1\033[0;30m
-----------------------------------------------------
\033[0m"
}


# LINKS
# ---------------------------------------------------------------------------------

wps_links() {

	if [[  ! $WPS_MYSQL == '127.0.0.1:3306'  ]];
	then echo -e "\033[1;32m  •\033[0;37m MySQL\033[0m -> $WPS_MYSQL"
	else echo -e "\033[1;33m  •\033[0;37m MySQL\033[0m -> $WPS_MYSQL (localhost)"
	fi	
	
	if [[  ! -z $WPS_REDIS  ]];
	then echo -e "\033[1;32m  •\033[0;37m Redis\033[0m -> $WPS_REDIS"		
	else echo -e "\033[1;31m  •\033[0;37m Redis\033[0m [not connected]"
	fi		
	
	if [[  ! -z $WPS_MEMCACHED  ]];
	then echo -e "\033[1;32m  •\033[0;37m Memcached\033[0m -> $WPS_MEMCACHED"
	else echo -e "\033[1;31m  •\033[0;37m Memcached\033[0m [not connected]"
	fi
}


# VERSION
# ---------------------------------------------------------------------------------

wps_version(){

	LOCK_VERSION=`cat $www/composer.json | grep 'johnpbloch/wordpress' | cut -d: -f2`
	
	if [[  ! -z $WP_VERSION  ]];
	then sed -i "s/$LOCK_VERSION/\"$WP_VERSION\"/g" $www/composer.json && su -l $user -c "cd $www && composer update"
	fi
}


# CHMOD
# ---------------------------------------------------------------------------------

wps_chmod() { 

	if [[  ! -f "$home/logs/php/php-fpm.log"  ]];  then touch $home/logs/php/php-fpm.log; fi
	if [[  ! -f "$home/logs/nginx/error.log"  ]];  then touch $home/logs/nginx/error.log; fi
	if [[  ! -f "$home/logs/nginx/access.log"  ]]; then touch $home/logs/nginx/access.log; fi

	sudo chown -R $user:nginx $home
	
	sudo find $home -type f -exec chmod 644 {} \;
	sudo find $home -type d -exec chmod 755 {} \;
}

# ADMINER
# ---------------------------------------------------------------------------------

wps_adminer() { 

	wps_header "Adminer (mysql admin)"

	echo -e "  Password: $DB_PASSWORD\n"
	php -S 0.0.0.0:8888 -t /usr/local/adminer
}
