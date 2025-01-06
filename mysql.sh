#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1 #other than 0
    fi
}

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT


dnf install mysql-server -y &>>LOG_FILE_NAME
VALIDATE $? "INSTALLING MYSQL SERVER"

systemctl enable mysqld &>>LOG_FILE_NAME
VALIDATE $? "ENABLING MYSQL"

systemctl start mysqld &>>LOG_FILE_NAME
VALIDATE $? "STARTING MYSQL"

mysql -h mysql.basam.site -u root -pExpenseApp@1 -e 'show databases;'

if [ $? -ne 0]
then
    echo "MYSQL root password not setup " &>>LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "SETTING UP ROOT PASSWORD"
else 
    echo -e "MYSQL root password is already setup .... $Y SKIPPING $N"
fi