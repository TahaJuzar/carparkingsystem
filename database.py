import psycopg2

def connect_to_db():
    conn = psycopg2.connect(
        dbname="car",
        user="postgres",
        password="Taha5253",
        host="localhost",
        port="5432"
    )
    cur = conn.cursor()
    return cur, conn

def fetch_data(cur, conn):
    cur.execute("SELECT * FROM mytable")
    results = cur.fetchall()
    return results

def close_connection(cur, conn):
    cur.close()
    conn.close()

if __name__ == "__main__":
    cur, conn = connect_to_db()
    data = fetch_data(cur, conn)
    print(data)  # You can print or use the data here
    close_connection(cur, conn)
