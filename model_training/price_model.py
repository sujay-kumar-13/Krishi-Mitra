import pandas as pd
import joblib
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

# Load dataset
df = pd.read_csv("final_prices.csv")  # Ensure this file exists

# Feature Engineering
df['date'] = pd.to_datetime(df['date'])
df['month'] = df['date'].dt.month
df['year'] = df['date'].dt.year

# Encode categorical variables
le_crop = LabelEncoder()
le_state = LabelEncoder()

df['crop_encoded'] = le_crop.fit_transform(df['crop'])
df['state_encoded'] = le_state.fit_transform(df['state'])

# Save encoders
joblib.dump(le_crop, "crop_encoder.pkl")
joblib.dump(le_state, "state_encoder.pkl")

# Define features and target
features = ['state_encoded', 'crop_encoded', 'year', 'month', 'temperature', 'rainfall', 'soil_moisture', 'ndvi']
target = 'price'

X = df[features]
y = df[target]

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train the model
model = RandomForestRegressor(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Save the trained model
joblib.dump(model, "price_model.pkl")

print("Model and encoders saved successfully!")
