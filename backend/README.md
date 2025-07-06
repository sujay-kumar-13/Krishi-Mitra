# Backend - Flask API for Krishi Mitra

This folder contains the Flask backend API that powers the Krishi Mitra app. It handles requests from the Flutter frontend, performs machine learning inference, and returns predictions and data.

---

## 📁 Folder Structure

```
backend/
├── app.py                # Main entry point for the Flask app
├── Dockerfile            # Production-ready Docker configuration for backend
├── *.pkl                 # Trained ML models and related files (saved using joblib)
├── .env                  # Environment variables (not tracked)
├── requirements.txt      # Python dependencies
└── README.md             # This file
```

---

## 🚀 Getting Started

### 1. Install Python dependencies

# Install dependencies
pip install -r requirements.txt
```

### 2. Setup Environment Variables

Create a `.env` file in the `backend/` folder:

```env
FLASK_ENV=development
FLASK_APP=app.py
GEMINI_API_KEY=your_secret_key
# Add any other keys here, e.g., Firebase, Gemini, etc.
```

### 3. Run the Flask App

```bash
flask run
```

By default, the app runs at: [http://127.0.0.1:5000](http://127.0.0.1:5000)

---

## 📡 API Endpoints

| Endpoint             | Method | Description                                                       |
|----------------------|--------|-------------------------------------------------------------------|
| `/detectDisease`     | POST   | Accepts crop image and returns disease prediction with medication |
| `/fertCalculator`    | POST   | Returns calculated fertilizer data based on input                 |
| `/cropsCollection`   | POST   | Returns crop data for frontend                                    |
| `/predict`           | POST   | Returns predicted price for the specified crop                    |

---

## 🧠 Technologies Used

- **Flask** – Web framework
- **Firebase Admin SDK** – To access Firebase
- **scikit-learn + joblib** – For ML model training and loading

---

## ✅ To Do / Improvements

- Add unit tests for API routes
- Add Swagger or Postman collection for API docs
- Add rate limiting and authentication

---

## ⚠️ Security Notes

- Do **not** commit `.env` or credentials like `firebase-adminsdk.json`
- Always validate and sanitize incoming data

---

## 📄 License

MIT License – free to use with attribution.