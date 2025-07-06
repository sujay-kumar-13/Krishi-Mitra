import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, root_mean_squared_error, r2_score


# 1. Load data
df = pd.read_csv("demand_crops.csv")

# 2. Date handling ➜ month / year
df["date"] = pd.to_datetime(df["date"])
df["month"] = df["date"].dt.month
df["year"]  = df["date"].dt.year
df.drop(columns=["date", "location"], inplace=True)

# 3. Encode categorical features
cat_cols = ["crop", "state"]
label_encoders = {}
for col in cat_cols:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col].astype(str))
    label_encoders[col] = le

# 4. Features & target
X = df.drop(columns=["demand"])
y = df["demand"]

# 5. Scale only numeric columns
num_cols = ["price", "marketing_spend", "competitor_price", "supply"]
scaler = StandardScaler()
X[num_cols] = scaler.fit_transform(X[num_cols])

# 6. Train / test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# 7. Model: RandomForest (free, built‑in)
model = RandomForestRegressor(
    n_estimators=300,
    max_depth=None,
    random_state=42,
    n_jobs=-1
)
model.fit(X_train, y_train)

# 8. Evaluate
y_pred = model.predict(X_test)
print(f"MAE : {mean_absolute_error(y_test, y_pred):.2f}")
print(f"RMSE: {root_mean_squared_error(y_test, y_pred):.2f}")
print(f"R²  : {r2_score(y_test, y_pred):.4f}")

# 9. Persist
joblib.dump(model,  "demand_model.pkl")
joblib.dump(scaler, "scalers.pkl")
joblib.dump(label_encoders, "label_encoder.pkl")
print("✅ Demand model & helpers saved!")
