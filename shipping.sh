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

dnf install maven -y
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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> LOGFILE
VALIDATE $? "downloading shipping application"

cd /app &>> LOGFILE
VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> LOGFILE
VALIDATE $? "unzipping shipping"

mvn clean package &>> LOGFILE
VALIDATE $? "installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> LOGFILE
VALIDATE $? "renaming jar file"

cp /home/centos/roboshop-shellscript/shipping.service /etc/systemd/system/shipping.service &>> LOGFILE
VALIDATE $? "copying shipping service"

systemctl daemon-reload &>> LOGFILE
VALIDATE $? "deamon reload"

systemctl enable shipping &>> LOGFILE
VALIDATE $? "enable shipping"

systemctl start shipping &>> LOGFILE
VALIDATE $? "start shipping"

dnf install mysql -y &>> LOGFILE
VALIDATE $? "install mysql client"

mysql -h mysql.daws80.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> LOGFILE
VALIDATE $? "loading shipping data"

systemctl restart shipping &>> LOGFILE
VALIDATE $? "restart shipping"