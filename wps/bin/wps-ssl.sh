
# SSL (https)
# ---------------------------------------------------------------------------------

wps_ssl() {

	wps_header "Creating SSL cert."

	if [[  ! -f $home/ssl/${HOSTNAME}.crt  ]]; then

	
		cd $home/ssl && rm -f $home/ssl/$HOSTNAME.*
		
		cat /wps/etc/nginx/openssl.conf | sed -e "s/example.com/$HOSTNAME/g" > openssl.conf
	
		openssl req -nodes -sha256 -newkey rsa:2048 -keyout $HOSTNAME.key -out $HOSTNAME.csr -config openssl.conf -batch
		openssl rsa -in $HOSTNAME.key -out $HOSTNAME.key
		openssl x509 -req -days 365 -sha256 -in $HOSTNAME.csr -signkey $HOSTNAME.key -out $HOSTNAME.crt	
	
		rm -f openssl.conf

	else echo -e "Certificate already exists.\nSkipping..."
	fi

	# -----------------------------------------------------------------------------	

	echo -e "`date +%Y-%m-%d\ %T` SSL setup completed." >> $home/log/wps/install.log	
}
