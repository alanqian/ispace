if [ -f /tmp/stores.csv ]; then
  rm /tmp/stores.csv
fi
if [ -f /tmp/categories.csv ]; then
  rm /tmp/categories.csv
fi
if [ -f /tmp/products.csv ]; then
  rm /tmp/products.csv
fi
if [ -f /tmp/sales.csv ]; then
  rm /tmp/sales.csv
fi

mysql ispace_dev < to_csv.sql

sed -i '' 's/\\N//g' /tmp/sales.csv
sed -i '' 's/\\N//g' /tmp/products.csv
sed -i '' 's/\\N//g' /tmp/categories.csv
sed -i '' 's/\\N//g' /tmp/stores.csv

mv /tmp/stores.csv ./csvs
mv /tmp/categories.csv ./csvs
mv /tmp/products.csv ./csvs
mv /tmp/sales.csv ./csvs
