#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-expense/"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MYSQL_HOST="mysql.learnwithdatta.online"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

mkdir -p $LOGS_FOLDER

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run the script with root user$N" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]; then
    echo "$2...FAILURE" | tee -a $LOGS_FILE
else
    echo "$2...SUCCESS" | tee -a $LOGS_FILE
fi
}

   dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling nodejs default version"
    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling NodeJS 20"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Installing NodeJS"

    npm install &>>$LOGS_FILE
    VALIDATE $? "Installing npm"

    rm -rf /usr/share/nginx/html/* &>>$LOGS_FILE
    VALIDATE $? "Removing default content"

    curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip  &>>$LOGS_FILE

    cd /usr/share/nginx/html &>>$LOGS_FILE
    VALIDATE "Chaging the directory to the app"

    unzip /tmp/frontend.zip &>>$LOGS_FILE
    VALIDATE $? "Downloaded and unzipped frontend"

    cp $SCRIPT_DIR/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGS_FILE
    VALIDATE $? "Copied our nginx conf file"

    systemctl enable nginx 
    VALIDATE $? "Enabled nginx"

    systemctl start nginx 
    VALIDATE $? "Started nginx"

