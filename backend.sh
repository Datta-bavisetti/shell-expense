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

dnf update -y openssh openssh-server openssh-clients &>>$LOGS_FILE
VALIDATE $? "Updating openssh"

useradd expense  &>>$LOGS_FILE
if [ $? -el 0 ]; then
    echo "Created expense user"
else
    echo "User already exists..$Y SKIPPING $N"
fi
mkdir /app  &>>$LOGS_FILE
VALIDATE $? "Created app directory"

curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOGS_FILE
cd /app  &>>$LOGS_FILE
VALIDATE $? "Chaging the directory to the app"

unzip /tmp/backend.zip  &>>$LOGS_FILE
VALIDATE $? "Downloaded and unzipped frontend"

npm install  &>>$LOGS_FILE
VALIDATE $? "Installing npm"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "daemon reload"

systemctl enable backend &>>$LOGS_FILE
systemctl start backend
VALIDATE $? "Enabled & Started backend service"

dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "Installing mysql"

mysql -h $MYSQL_HOST -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$
VALIDATE $? "App data loaded"

systemctl restart backend &>>$LOGS_FILE
VALIDATE $? "Restarted backend service"

