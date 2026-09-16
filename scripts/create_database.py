import sqlite3
import pandas as pd
from pathlib import Path

data_dir = Path("data")
db_path = data_dir / "olist.db"

tables = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "payments": "olist_order_payments_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "reviews": "olist_order_reviews_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}

conn = sqlite3.connect(db_path)

for table_name, file_name in tables.items():
    df = pd.read_csv(data_dir / file_name)
    df.to_sql(table_name, conn, if_exists="replace", index=False)
    print(f"{table_name}: {len(df)} rows")

conn.close()

print("Database created.")