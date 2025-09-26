#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-roboshop/mongodb.log
MONGODB_HOST="mongodb.born96.fun"


mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e  "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}
    
    ###Nodejs######
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling the nodejs"

dnf  module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable the nodesjs"


dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "insall the modesjs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "enable the nodesjs"

mkdir /app  &>>$LOG_FILE    
VALIDATE $? "creating a directory name as "app"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading the code"

cd /app &>>$LOG_FILE
VALIDATE $? "change the directory to app"


unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip the downloaded code"

npm install &>>$LOG_FILE
VALIDATE $? "install dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATE $? "copying the catalogue.service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "running the daemon reload"



systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enable the catalogue"

systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "start the catalogue"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "copying the mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "install the mongodb"

mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "Loading the catalogue products"

systemctl restart catalogue
VALIDATE $? "Restarting the catalogue"