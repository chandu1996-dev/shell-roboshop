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
SCRIPT_DIR=$PWD
start_TIME=$(date +%s)


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
VALIDATE $? "install the modesjs"

id roboshop
    if [ $? -ne 0 ]; then

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE   
    VALIDATE $? "creating user"
else
 echo -e "User already exists ...$Y Skipping $N"
fi

mkdir -p /app  &>>$LOG_FILE    
VALIDATE $? "creating a directory name as app"


curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "downlod the catalogue application"

cd /app 
VALIDATE $? "change directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"


unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "unzip the code"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service 
VALIDATE $? "copying systemctl services"


systemctl daemon-reload 
VALIDATE $? "daemon reloading"


systemctl enable user  &>>$LOG_FILE
VALIDATE $? "enable the catalogue"

systemctl start user  &>>$LOG_FILE
VALIDATE $? "start the catalogue"

END_TIME=$(date +%s)

TOTAL_TIME=$(($END_TIME - $start_TIME))
echo -e "script excuted in : $Y $TOTAL_TIME seconds : $N"