#!/bin/bash

souce ./common.sh
app_name=shipping

check_root
echo "please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

app_setup
maven_setup
systemd_setup

dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "install mysql"

mysql -h mysql.dineshkonda.site -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE

if [ $? -ne 0 ]
then
    mysql -h mysql.dineshkonda.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql  &>>$LOG_FILE
    mysql -h mysql.dineshkonda.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h mysql.dineshkonda.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql  &>>$LOG_FILE
    VALIDATE $? "Loading data into mysql"
else 
    echo -e "data is already loaded in mysql... $Y SKIPPING $N"
fi

systemctl restart shipping  &>>$LOG_FILE
VALIDATE $? "restart shipping"

print_time