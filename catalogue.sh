#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.daws80.online
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> LOGFILE
VALIDATE $? "installing dependencies"

dnf module enable nodejs:18 -y  &>> LOGFILE
VALIDATE $? "enabling  nodejs -18"

dnf install nodejs -y  &>> LOGFILE
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
  useradd roboshop
  VALIDATE $? "creating roboshop user"
else
  echo -e "roboshop user already exist $Y skipping
  $N"
fi

mkdir -p /app &>> LOGFILE
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> LOGFILE
VALIDATE $? "downloading catalogue appliaction "

cd /app  &>> LOGFILE
VALIDATE $? "change to app directory"

unzip -o /tmp/catalogue.zip &>> LOGFILE # -o for override
VALIDATE $? "unzipping ctalogue application"

npm install &>> LOGFILE
VALIDATE $? "unzipping catalogue application"

#use absolute path because catalogue.service exists there
cp  /home/centos/roboshop-shellscript/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copying catalogue service file"

systemctl daemon-reload  &>> LOGFILE
VALIDATE $? "catalogue deamon reload"

systemctl enable catalogue &>> LOGFILE
VALIDATE $? "enable catalogue"

systemctl start catalogue &>> LOGFILE
VALIDATE $? "start catalogue"

cp /home/centos/roboshop-shellscript/mongo.repo /etc/yum.repos.d/mongo.repo &>> LOGFILE
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> LOGFILE
VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js  &>> LOGFILE
VALIDATE $? "loading catalogue data into mongodb"
