from flask import Flask, request, jsonify, render_template
import database

app = Flask(__name__)

# Route to handle parking submission
@app.route('/parking', methods=['POST'])
def park_car():
    data = request.json
    print(data)


    # Extract data from the JSON payload
    owner_name = data.get('ownerName')
    print(owner_name)
    car_number = data.get('carNumber')
    car_model = data.get('carModel')
    phone_number = data.get('phoneNumber')


    # Insert data into the database
    cur, conn = database.connect_to_db()

    cur.execute("INSERT INTO car_information (Owner_Name, Car_Number, Car_Model, Phone_Number) VALUES (%s, %s, %s, %s)",
                (owner_name, car_number, car_model, phone_number))
    conn.commit()
    database.close_connection(cur, conn)
    
    response_data = {'message': 'Car information added successfully'}
    print('Response:', response_data)  # Log the response data
    return jsonify(response_data)

# Route to retrieve all parked cars
@app.route('/parking', methods=['GET'])
def get_parked_cars():
    # Fetch data from the database
    cur, conn = database.connect_to_db()
    results = database.fetch_data(cur, conn)
    database.close_connection(cur, conn)
    # Convert results to a list of dictionaries for JSON serialization
    parked_cars = [{'Owner_Name': row[0], 'Car_Model': row[1], 'Car_Number': row[2], 'Phone_Number' : row[3]} for row in results]
    return jsonify(parked_cars)

@app.route('/', methods=['GET'])
def hi():
    return render_template('admin.html')

if __name__ == '__main__':
    app.run(debug=True)
