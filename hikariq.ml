server {
	listen 80;
	listen [::]:80;

	root /var/www/html;

	server_name hikariq.ml www.hikariq.ml;

	location / {
		try_files $uri $uri/ =404;
	}
}
