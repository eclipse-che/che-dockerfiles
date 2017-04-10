FROM mysql
EXPOSE 3306
CMD mysql -uroot -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '"$MYSQL_PASSWORD"'" && \
    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '"$MYSQL_PASSWORD"'; FLUSH PRIVILEGES;" && \
    mysql -uroot -e "CREATE DATABASE $MYSQL_DATABASE;" && \
    tail -f /dev/null
