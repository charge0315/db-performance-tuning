#!/bin/bash
cd /mnt/c/Users/charg/myWorkspace/db-performance-tuning
echo "Waiting for MySQL initialization (up to 5 min)..."
for i in $(seq 1 60); do
  sleep 5
  if docker exec sql-tuning-mysql mysqladmin ping -ppassword --silent 2>/dev/null; then
    echo "MySQL ready! Checking data..."
    docker exec sql-tuning-mysql mysql -uroot -ppassword sakila \
      -e "SELECT COUNT(*) as film_count FROM film; SELECT COUNT(*) as actor_count FROM actor; SELECT COUNT(*) as customer_count FROM customer;" 2>&1
    exit 0
  fi
  echo "  $i/60 waiting..."
done
echo "Timeout"
