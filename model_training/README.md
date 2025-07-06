# Crop Demand and Price Prediction Models

This repository contains two Python scripts designed for training models:

* **Crop Demand Prediction:** Forecasts the demand for various crops.
* **Crop Price Prediction:** Predicts the future price of crops.

Both models use a **RandomForestRegressor** and are trained on specific datasets. After training, the models and their associated pre-processing tools (like data scalers and label encoders) are saved as `.pkl` files for easy reuse in making future predictions.

---

## 📝 Uses and Functionalities

### 1. Crop Demand Prediction Model

* **Purpose:** To predict the **demand for crops**.
* **Functionality:**
    * Reads historical data from `demand_crops.csv`.
    * Processes dates to extract month and year information.
    * Converts categorical data (crop names, states) into numerical formats using **Label Encoding**.
    * Scales numerical features (like price and supply) to standardize them.
    * Trains a **RandomForestRegressor** model.
    * Evaluates the model's performance using metrics like MAE, RMSE, and R-squared.
    * Saves the trained model (`demand_model.pkl`), the data scaler (`scalers.pkl`), and the label encoders (`label_encoder.pkl`) for future predictions.

### 2. Crop Price Prediction Model

* **Purpose:** To predict the **market price of crops**.
* **Functionality:**
    * Reads data from `final_prices.csv`.
    * Extracts month and year from date information.
    * Encodes categorical data (crop names, states) into numerical formats.
    * Trains a **RandomForestRegressor** model based on features like state, crop, year, month, temperature, rainfall, soil moisture, and NDVI.
    * Saves the trained model (`price_model.pkl`) and the specific label encoders for crop and state (`crop_encoder.pkl`, `state_encoder.pkl`).

---

## 📂 Files

```
model_training/
├── train_demand_model.py
├── train_price_model.py
├── demand_crops.csv
├── final_prices.csv
├── requirements.txt
└── README.md
```

---

## 🚀 How to Use

### 1. Install dependencies

```bash
pip install requirements
```

### 2. Run the script

```bash
python price_model.py
```
```bash
python demand_model.py
```

If the CSV files are present in the same directory, it will create various `.pkl` files in the same folder.
