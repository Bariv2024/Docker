#!/bin/bash

ping_and_save() {
    local host=$1
    local output_file=$2
    ping -c 4 $host > $output_file
    if grep -q "100% packet loss" $output_file; then
        echo "Ping to $host failed" >> $output_file
        return 1
    else
        echo "Ping to $host succeeded" >> $output_file
        return 0
    fi
}

ping_and_save nginx_container /mnt/external_folder/ping_nginx.txt

ping_and_save postgres_container /mnt/external_folder/ping_postgres.txt

if [ -f /mnt/external_folder/ping_nginx.txt ] && grep -q "Ping to nginx_container succeeded" /mnt/external_folder/ping_nginx.txt; then
    curl http://nginx_container -o /mnt/external_folder/nginx_page.html
fi

PGPASSWORD="postgres" psql -h postgres_container -U postgres -d postgres -c "\conninfo" > /mnt/external_folder/db_connectivity.txt

tail -f /dev/null