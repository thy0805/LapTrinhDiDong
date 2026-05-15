import json
import os
import numpy as np
import tensorflow as tf
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io
import uvicorn

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "vietnamese_food_mobilenetv2.keras")
JSON_PATH = os.path.join(BASE_DIR, "class_indices.json")

def build_model():
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(224, 224, 3), 
        include_top=False, 
        weights=None
    )
    model = tf.keras.Sequential([
        base_model,
        tf.keras.layers.GlobalAveragePooling2D(),
        tf.keras.layers.Dense(30, activation='softmax')
    ])
    return model

model = build_model()
model.load_weights(MODEL_PATH)

with open(JSON_PATH, "r", encoding="utf-8") as f:
    class_names = json.load(f)

FOOD_CALORIES = {
    "banh_beo": 268,
    "banh_bot_loc": 280,
    "banh_can": 300,
    "banh_canh": 350,
    "banh_chung": 1500,
    "banh_cuon": 300,
    "banh_duc": 200,
    "banh_gio": 400,
    "banh_khot": 350,
    "banh_mi": 460,
    "banh_pia": 400,
    "banh_tet": 1600,
    "banh_trang_nuong": 380,
    "banh_xeo": 350,
    "bun_bo_hue": 479,
    "bun_dau_mam_tom": 550,
    "bun_mam": 450,
    "bun_rieu": 400,
    "bun_thit_nuong": 500,
    "ca_kho_to": 300,
    "canh_chua": 200,
    "cao_lau": 450,
    "chao_long": 350,
    "com_tam": 650,
    "goi_cuon": 150,
    "hu_tieu": 400,
    "mi_quang": 450,
    "nem_chua": 130,
    "pho": 400,
    "xoi_xeo": 400
}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).convert("RGB")
    image = image.resize((224, 224))
    
    img_array = tf.keras.preprocessing.image.img_to_array(image)
    img_array = tf.expand_dims(img_array, 0)
    img_array = tf.keras.applications.mobilenet_v2.preprocess_input(img_array)
    
    predictions = model.predict(img_array)[0]
    
    top_5_indices = predictions.argsort()[-5:][::-1]
    
    results = []
    for i in top_5_indices:
        food_id = class_names[i]
        results.append({
            "id": food_id,
            "confidence": float(predictions[i]),
            "calories": FOOD_CALORIES.get(food_id, 0)
        })
        
    return {"predictions": results}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)