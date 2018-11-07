#!/bin/bash
path="/Desktop/CFH_London_Backup"
repositorypath="/Desktop/tick_data/AWS_london"
dbUser='username'
dbPassword='password'
backdbUser='username'
backdbPassword='password'
cd $path;

date=$(date -d "+0 day $1" +%Y%m%d)
enddate=$(date -d "-1 day $2" +%Y%m%d)

echo "----------"
echo "date=$date"
echo "enddate=$enddate"
echo "----------"

while [[ ${date} < ${enddate} ]]
do
for value in `mysql -h ipaddress -u$dbUser -p$dbPassword -e"select table_name from information_schema.tables where table_schema='spread'"`
do
if [[ ${value} == "${date}"* ]];then 

echo "export" $value.sql
mysqldump -h ipaddress -u$dbUser -p$dbPassword --skip-lock-tables spread $value | sed 's/ AUTO_INCREMENT=[0-9]*\b//' > $value.sql

echo "import" $value.sql
mysql -h ipaddress -u$backdbUser -p$backdbPassword cfh_sub < $value.sql;

echo "move" $value.sql "to fileserver"
mv -f $value.sql $repositorypath
fi
done
date=$(date -d "+1 day $date" +%Y%m%d)
done
echo 'OK!'
