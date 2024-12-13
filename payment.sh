#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install python36 gcc python3-devel -y &>> LOGFILE
VALIDATE $? "installing python"

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
VALIDATE $? "creating payment app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> LOGFILE
VALIDATE $? "downloading payment application"

cd /app &>> LOGFILE
VALIDATE $? "moving to app directory"

unzip -o /tmp/payment.zip &>> LOGFILE
VALIDATE $? "unzipping application"

pip3.6 install -r requirements.txt &>> LOGFILE
VALIDATE $? "installing DEPENDENCIES"

cp /home/centos/roboshop-shellscript/payment.service /etc/systemd/system/payment.service &>> LOGFILE
VALIDATE $? "copying payment service"

systemctl daemon-reload &>> LOGFILE
VALIDATE $? "reload deamon service"

systemctl enable payment &>> LOGFILE
VALIDATE $? "enabling payment application"

systemctl start payment &>> LOGFILE
VALIDATE $? "starting payment application"