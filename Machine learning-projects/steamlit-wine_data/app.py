from flask import Flask, render_template, request
import pickle
import numpy as np

app = Flask(__name__)

# Load the pickle model
model = pickle.load(open('wine_data.pkl', 'rb'))

@app.route('/')
def home():
    return render_template('index.html', prediction=None)

@app.route('/predict', methods=['POST'])
def predict():
    # Get form data
    citric_acid = float(request.form['citric_acid'])
    residual_sugar = float(request.form['residual_sugar'])
    chlorides= float(request.form['chlorides'])
    # Create a numpy array with the form data

    # Create a numpy array with the form data
    data = np.array([[citric_acid,residual_sugar,chlorides]])

    # Make prediction using the loaded model
    prediction = model.predict(data)[0]

    # Render the template with the prediction
    return render_template('index.html', prediction=round(prediction, 2))

if __name__ == '__main__':
    app.run(debug=True)
    #app.run(host='0.0.0.0',port=8000)
