curl --insecure -s https://localhost/ 1>/dev/null;
if [ $? -eq 7 ]; then
echo "`date` \t Could not setup HTTP connection to localhost" >> /var/log/webdown.log;
service nginx restart
fi
