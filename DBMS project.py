import psycopg2
from psycopg2 import Error

# Function to establish a database connection
def create_connection():
    connection = None
    try:
        connection = psycopg2.connect(
            database="car",
            user="postgres",
            password="Taha5253",
            host="localhost",
            port="5432"
        )
        print("Connection to PostgreSQL DB successful")
    except Error as e:
        print(f"The error '{e}' occurred")
    return connection

# Sample function to execute a query and fetch results
def execute_query(connection, query):
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        return cursor.fetchall()
    except Error as e:
        print(f"The error '{e}' occurred")
        return None
    finally:
        cursor.close()

# Sample function to list available parking lots
def list_available_parking_lots(connection):
    query = "SELECT Lot_ID, Location, Capacity, Current_Availability FROM Parking_Lots WHERE Current_Availability > 0;"
    results = execute_query(connection, query)
    if results:
        for row in results:
            print(row)

# Sample function to find total revenue earned in a given period
def find_total_revenue(connection):
    query = "SELECT SUM(Parking_Fee) AS Total_Revenue FROM Parking_Records WHERE Exit_Time BETWEEN NOW() - INTERVAL '1 DAY' AND NOW();"
    result = execute_query(connection, query)
    if result:
        print("Total Revenue:", result[0][0])

# Connect to the database
connection = create_connection()

# Example usage of functions
if connection:
    list_available_parking_lots(connection)
    find_total_revenue(connection)

    # Don't forget to close the connection when done
    connection.close()
