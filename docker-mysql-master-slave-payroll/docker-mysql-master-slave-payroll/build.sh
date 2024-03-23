#!/bin/bash

docker compose down
rm -rf ./master/data/* ./master/data/.gitkeep
rm -rf ./slave/data/* ./slave/data/.gitkeep
chmod 044 ./master/conf/mysql.conf.cnf
chmod 044 ./slave/conf/mysql.conf.cnf
docker compose build
docker compose up -d

until docker exec mysql_master sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_master database connection..."
    sleep 4
done

priv_stmt='GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user"@"%" IDENTIFIED BY "mydb_slave_pwd"; FLUSH PRIVILEGES;'
docker exec mysql_master sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt'"

until docker-compose exec mysql_slave sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_slave database connection..."
    sleep 4
done

priv_stmt2='GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user2"@"%" IDENTIFIED BY "mydb_slave_pwd2"; FLUSH PRIVILEGES;'
docker exec mysql_master sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt2'"

until docker-compose exec mysql_slave2 sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_slave2 database connection..."
    sleep 4
done

priv_stmt3='GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user3"@"%" IDENTIFIED BY "mydb_slave_pwd3"; FLUSH PRIVILEGES;'
docker exec mysql_master sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt3'"

until docker-compose exec mysql_slave3 sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_slave3 database connection..."
    sleep 4
done

priv_stmt4='GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user4"@"%" IDENTIFIED BY "mydb_slave_pwd4"; FLUSH PRIVILEGES;'
docker exec mysql_master sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt4'"

until docker-compose exec mysql_slave4 sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_slave4 database connection..."
    sleep 4
done

docker-ip() {
    docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

MS_STATUS=`docker exec mysql_master sh -c 'export MYSQL_PWD=111; mysql -u root -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $5}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $6}'`

start_slave_stmt="RESET SLAVE;CHANGE MASTER TO MASTER_HOST='$(docker-ip mysql_master)',MASTER_USER='mydb_slave_user',MASTER_PASSWORD='mydb_slave_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'
echo "$start_slave_cmd"
docker exec mysql_slave sh -c "$start_slave_cmd"


start_slave_stmt2="RESET SLAVE;CHANGE MASTER TO MASTER_HOST='$(docker-ip mysql_master)',MASTER_USER='mydb_slave_user2',MASTER_PASSWORD='mydb_slave_pwd2',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd2='export MYSQL_PWD=111; mysql -u root -e "'
start_slave_cmd2+="$start_slave_stmt2"
start_slave_cmd2+='"'
echo "$start_slave_cmd2"
docker exec mysql_slave2 sh -c "$start_slave_cmd2"


start_slave_stmt3="RESET SLAVE;CHANGE MASTER TO MASTER_HOST='$(docker-ip mysql_master)',MASTER_USER='mydb_slave_user3',MASTER_PASSWORD='mydb_slave_pwd3',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cm3='export MYSQL_PWD=111; mysql -u root -e "'
start_slave_cmd3+="$start_slave_stmt3"
start_slave_cmd3+='"'
echo "$start_slave_cmd3"
docker exec mysql_slave3 sh -c "$start_slave_cmd3"


start_slave_stmt4="RESET SLAVE;CHANGE MASTER TO MASTER_HOST='$(docker-ip mysql_master)',MASTER_USER='mydb_slave_user4',MASTER_PASSWORD='mydb_slave_pwd4',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd4='export MYSQL_PWD=111; mysql -u root -e "'
start_slave_cmd4+="$start_slave_stmt4"
start_slave_cmd4+='"'
echo "$start_slave_cmd4"
docker exec mysql_slave sh -c "$start_slave_cmd4"




docker exec mysql_slave4 sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
docker exec mysql_slave3 sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
docker exec mysql_slave2 sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
docker exec mysql_slave sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
docker exec mysql_master sh -c "export MYSQL_PWD=111; mysql -u root mydb < /db/mydb.sql"