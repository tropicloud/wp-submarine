
wps_setup() {
	
	# SYSTEM
	# ---------------------------------------------------------------------------------

	logs="msmtp nginx php supervisor wps"
	
	for d in $logs; do 
		mkdir -p $home/logs/$d
	done	

	if [[  ! -f $home/.env  ]]; then wps_env; fi
	if [[  $WPS_MYSQL == '127.0.0.1:3306'  ]]; then wps_mysql_install; fi
	if [[  $WP_SSL == 'true'  ]]; then wps_ssl && mv $conf/nginx/https.conf $conf/nginx/conf.d; fi

	
	# WORDPRESS
	# ---------------------------------------------------------------------------------
	
	wps_header "Installing WordPress"
	
	su -l $user -c "git clone $WP_REPO $www" && wps_version
	su -l $user -c "cd $www && composer install"
	ln -s $home/.env $www/.env

	wps_wp_install > $home/logs/wps/install.log 2>&1 & 			
		
	echo -ne "Loading environment..."
	while ! wps_wp_ready; do 
		echo -n '.' && sleep 1
	done && echo -ne " done.\n"
	
	# -----------------------------------------------------------------------------	

	# fix "The mysql extension is deprecated and will be removed in the future: use mysqli or PDO"
	sed -i "s/define('WP_DEBUG'.*/define('WP_DEBUG', false);/g" $www/config/environments/development.php

	echo -e "`date +%Y-%m-%d\ %T` WordPress setup completed." >> $home/logs/wps/setup.log	
}
