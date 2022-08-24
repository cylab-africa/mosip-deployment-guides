ping $1 -c 3 1>/dev/null;
if [ $? -eq 1 ]; then
echo "`date` \t Ping to $1 failed " >> /var/log/downcheck.log;
vagrant reload console
fi
