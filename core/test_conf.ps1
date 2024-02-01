return "" +
@"
<Directory "`${project_dir}/test">
    Options Indexes FollowSymLinks MultiViews Includes ExecCGI
	AllowOverride All
	Require all granted
</Directory>

<VirtualHost 0.0.0.0:80>
    ServerName test.dev.win
    DocumentRoot "`${project_dir}/test"

	Redirect permanent / https://test.dev.win/
</VirtualHost>

<VirtualHost 0.0.0.0:443>
    ServerName test.dev.win
    DocumentRoot "`${project_dir}/test"

	SSLEngine on
	SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP:+eNULL
	SSLCertificateFile "`${ssl_dir}/star.crt"
	SSLCertificateKeyFile "`${ssl_dir}/star.key"
</VirtualHost>
"@