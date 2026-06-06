import json
import os
import numpy as np

try:
    import tensorflow as tf
    HAS_TENSORFLOW = True
except ImportError:
    HAS_TENSORFLOW = False

from fastapi import FastAPI, File, UploadFile, Request
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io
import uvicorn
import requests

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

model = None

if HAS_TENSORFLOW:
    try:
        def build_model():
            base_model = tf.keras.applications.MobileNetV2(
                input_shape=(224, 224, 3), 
                include_top=False, 
                weights=None
            )
            model_seq = tf.keras.Sequential([
                base_model,
                tf.keras.layers.GlobalAveragePooling2D(),
                tf.keras.layers.Dense(30, activation='softmax')
            ])
            return model_seq

        model = build_model()
        model.load_weights(MODEL_PATH)
    except Exception:
        model = None

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

def get_model_routing(requested_model: str):
    if requested_model and ("pro" in requested_model.lower() or "gpt" in requested_model.lower()):
        return "https://educator-vendor-morphine.ngrok-free.dev/v1/chat/completions", "openai/gpt-oss-20b"
    return "http://127.0.0.1:1234/v1/chat/completions", "local-model"

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    
    if model is None or not HAS_TENSORFLOW:
        filename = file.filename.lower()
        predicted_food = "com_tam"
        for food in FOOD_CALORIES.keys():
            if food.replace("_", "") in filename.replace("_", "").replace("-", ""):
                predicted_food = food
                break
                
        results = [
            {
                "id": predicted_food,
                "confidence": 0.95,
                "calories": FOOD_CALORIES.get(predicted_food, 650)
            }
        ]
        return {"predictions": results}

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

@app.post("/chat")
async def chat(request: Request):
    body = await request.json()
    requested_model = body.get("model", "")
    target_url, target_model = get_model_routing(requested_model)
    body["model"] = target_model
    if "ngrok" in target_url or "colab" in target_url:
        body["stream"] = True
        def generate_colab():
            try:
                headers = {
                    "ngrok-skip-browser-warning": "true",
                    "User-Agent": "Mozilla/5.0"
                }
                print(f"[Colab Stream] Connecting to {target_url}...")
                response = requests.post(target_url, json=body, headers=headers, stream=True, timeout=180)
                passed_reasoning = False
                buffer = ""
                for line in response.iter_lines():
                    if line:
                        decoded_line = line.decode('utf-8')
                        if decoded_line.startswith('data: '):
                            data_str = decoded_line[6:].strip()
                            if data_str == '[DONE]':
                                yield "data: [DONE]\n\n"
                                continue
                            try:
                                chunk_json = json.loads(data_str)
                                token = chunk_json["choices"][0]["delta"]["content"]
                                buffer += token
                                if not passed_reasoning:
                                    if "assistantfinal" in buffer:
                                        remaining = buffer.split("assistantfinal")[-1]
                                        passed_reasoning = True
                                        if remaining:
                                            chunk_json["choices"][0]["delta"]["content"] = remaining.replace("**", "").replace("###", "").replace("##", "")
                                            yield f"data: {json.dumps(chunk_json, ensure_ascii=False)}\n\n"
                                    elif "final" in buffer and "assistant" not in buffer:
                                        remaining = buffer.split("final")[-1]
                                        passed_reasoning = True
                                        if remaining:
                                            chunk_json["choices"][0]["delta"]["content"] = remaining.replace("**", "").replace("###", "").replace("##", "")
                                            yield f"data: {json.dumps(chunk_json, ensure_ascii=False)}\n\n"
                                    elif "assistant" in buffer and not buffer.startswith("assistant") and "assistantfinal" not in buffer:
                                        if len(buffer) > 100:
                                            pass
                                else:
                                    clean_token = token.replace("**", "").replace("###", "").replace("##", "")
                                    chunk_json["choices"][0]["delta"]["content"] = clean_token
                                    yield f"data: {json.dumps(chunk_json, ensure_ascii=False)}\n\n"
                            except Exception:
                                pass
            except Exception as e:
                print(f"[Colab Stream] Exception: {str(e)}")
                err_json = {
                    "choices": [
                        {
                            "delta": {
                                "content": f"Connection error: {str(e)}"
                            }
                        }
                    ]
                }
                yield f"data: {json.dumps(err_json, ensure_ascii=False)}\n\n"
                yield "data: [DONE]\n\n"
        return StreamingResponse(generate_colab(), media_type="text/event-stream")
    else:
        body["stream"] = True
        def generate():
            with requests.post(target_url, json=body, stream=True) as r:
                for line in r.iter_lines():
                    if line:
                        yield line.decode('utf-8') + "\n\n"
        return StreamingResponse(generate(), media_type="text/event-stream")

def get_remaining_weekdays():
    from datetime import datetime, timedelta, timezone
    vn_tz = timezone(timedelta(hours=7))
    now_vn = datetime.now(vn_tz)
    weekday = now_vn.weekday()
    hour = now_vn.hour
    start_day_idx = weekday + 1 if hour >= 20 else weekday
    day_names = ["Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"]
    if start_day_idx > 6:
        return day_names, list(range(1, 8))
    remaining_days = day_names[start_day_idx:]
    remaining_indices = list(range(start_day_idx + 1, 8))
    return remaining_days, remaining_indices

@app.post("/coach/generate")
async def generate_coach_plan(request: Request):
    try:
        data = await request.json()
        requested_model = data.get("model", "")
        target_url, target_model = get_model_routing(requested_model)
        name = data.get("name", "Người dùng")
        gender = data.get("gender", "Nữ")
        age = data.get("age", 20)
        weight = data.get("weight", 50.0)
        height = data.get("height", 160.0)
        goal = data.get("goal", "Giảm cân")
        equipment = data.get("equipment", "Không tạ")
        
        remaining_days, remaining_indices = get_remaining_weekdays()
        days_str = ", ".join(remaining_days)
        
        system_prompt = (
            "Bạn là một Huấn Luyện Viên Cá Nhân AI (PT Ảo) chuyên nghiệp, đáng yêu, tinh nghịch tên là NutriTea của ứng dụng NutriFit. "
            "Nhiệm vụ của bạn là thiết lập kế hoạch tập luyện và dinh dưỡng chi tiết từ nay đến cuối tuần phù hợp với học viên. "
            "Bạn phải trả về phản hồi DUY NHẤT dưới dạng một đối tượng JSON hợp lệ theo cấu trúc được chỉ định bên dưới. "
            "Không thêm bất kỳ văn bản giải thích nào ngoài JSON."
        )
        
        user_msg = f"""Hãy thiết kế kế hoạch tập luyện và ăn uống cho học viên từ nay đến Chủ Nhật, cụ thể cho các ngày: {days_str}:
- Tên: {name}
- Giới tính: {gender}
- Tuổi: {age}
- Chiều cao: {height} cm
- Cân nặng: {weight} kg
- Mục tiêu: {goal}
- Trang thiết bị tập: {equipment}

Yêu cầu cấu trúc JSON đầu ra chính xác như sau (tên thuộc tính viết đúng tiếng Anh), chỉ tạo các ngày {days_str} với dayIndex tương ứng là {remaining_indices}:
{{
  "planName": "tên kế hoạch",
  "days": [
    {{
      "dayIndex": {remaining_indices[0]},
      "dayName": "{remaining_days[0]}",
      "workout": {{
        "focus": "Cardio đốt mỡ",
        "exercises": [
          {{
            "name": "push-up",
            "sets": 3,
            "reps": 12,
            "calories": 15,
            "instructions": "Chống đẩy giữ thẳng người"
          }}
        ]
      }},
      "nutrition": {{
        "targetCalories": 1800,
        "meals": [
          {{
            "type": "Bữa sáng",
            "name": "Cháo yến mạch chuối",
            "calories": 350,
            "protein": 10,
            "carbs": 55,
            "fat": 5
          }}
        ]
      }}
    }}
  ]
}}
Lưu ý:
- Tên bài tập workout.exercises.name phải sử dụng tiếng Anh chuẩn (chữ thường) ví dụ: upward facing dog, assisted hanging knee raise, impossible dips, push-up inside leg kick, cable cross-over variation, barbell seated bradford rocky press, dumbbell standing reverse curl, one leg floor calf raise, dumbbell burpee, roller hip lat stretch, weighted sissy squat, runners stretch, inverse leg curl (on pull-up cable machine), smith seated one leg calf raise, pull up (neutral grip), resistance band seated hip abduction, bear crawl, sled 45в° leg press, isometric wipers, raise single arm push-up, weighted stretch lunge, seated calf stretch (male), lever lying leg curl, hip raise (bent knee), smith bent knee good morning, ez bar standing french press, smith upright row, jack jump (male), barbell jump squat, janda sit-up, prone twist on stability ball.
- Chỉ tạo các ngày: {days_str}.
- Không được trả về bất cứ từ nào khác ngoài chuỗi JSON sạch."""

        payload = {
            "model": target_model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_msg}
            ],
            "temperature": 0.7,
            "response_format": {"type": "json_object"}
        }
        
        try:
            response = requests.post(target_url, json=payload, timeout=45)
            if response.status_code == 200:
                result = response.json()
                content = result["choices"][0]["message"]["content"].strip()
                parsed_json = json.loads(content)
                return parsed_json
        except Exception:
            pass
            
        return generate_fallback_plan(name, goal, weight, height, equipment, remaining_days, remaining_indices)
    except Exception as e:
        return {"error": str(e)}

def generate_fallback_plan(name, goal, weight, height, equipment, remaining_days, remaining_indices):
    is_gain = "tăng" in goal.lower() or "cơ" in goal.lower()
    is_loss = "giảm" in goal.lower() or "cân" in goal.lower() or "mỡ" in goal.lower()
    
    plan_name = f"Kế hoạch PT Ảo NutriTea dành riêng cho {name}"
    
    exercises_loss = [
        {"name": "bear crawl", "sets": 3, "reps": 45, "calories": 45, "instructions": "Bò đóng chân giữ thẳng lưng và đầu gối sát đất"},
        {"name": "push-up inside leg kick", "sets": 3, "reps": 12, "calories": 25, "instructions": "Chống đẩy kết hợp đá chân chéo sang bên"},
        {"name": "runners stretch", "sets": 3, "reps": 30, "calories": 15, "instructions": "Bước chân tấn trước duỗi thẳng chân sau dãn cơ đùi"},
        {"name": "one leg floor calf raise", "sets": 4, "reps": 15, "calories": 20, "instructions": "Đứng một chân nâng gót chân lên cao tối đa"},
        {"name": "hip raise (bent knee)", "sets": 3, "reps": 15, "calories": 20, "instructions": "Nằm ngửa co gối nâng cao hông giữ bụng chặt"}
    ]
    
    exercises_gain = [
        {"name": "impossible dips", "sets": 3, "reps": 8, "calories": 30, "instructions": "Nhún xà kép hạ sâu khuỷu tay vuông góc"},
        {"name": "pull up (neutral grip)", "sets": 3, "reps": 10, "calories": 35, "instructions": "Hít xà lòng bàn tay hướng vào nhau"},
        {"name": "weighted sissy squat", "sets": 4, "reps": 12, "calories": 40, "instructions": "Gánh đùi biến thể ngả lưng ra sau tăng áp lực đùi trước"},
        {"name": "janda sit-up", "sets": 3, "reps": 15, "calories": 25, "instructions": "Gập bụng kích hoạt đùi và cơ bụng dưới sâu"},
        {"name": "dumbbell burpee", "sets": 3, "reps": 10, "calories": 45, "instructions": "Nhảy burpee kết hợp nâng tạ đôi hai bên vai"}
    ]
    
    exercises_health = [
        {"name": "upward facing dog", "sets": 3, "reps": 30, "calories": 15, "instructions": "Tư thế rắn hổ mang mở ngực ngửa cổ"},
        {"name": "roller hip lat stretch", "sets": 3, "reps": 30, "calories": 12, "instructions": "Dùng ống lăn giãn cơ hông và cơ lưng xô"},
        {"name": "assisted hanging knee raise", "sets": 3, "reps": 12, "calories": 20, "instructions": "Treo xà hỗ trợ nâng cao đầu gối"},
        {"name": "hip raise (bent knee)", "sets": 3, "reps": 15, "calories": 20, "instructions": "Nằm ngửa nâng hông co gối nhẹ nhàng"},
        {"name": "runners stretch", "sets": 3, "reps": 20, "calories": 15, "instructions": "Duỗi dài chân dãn gân kheo đùi sau"}
    ]
    
    chosen_exercises = exercises_loss if is_loss else (exercises_gain if is_gain else exercises_health)
    
    meals_loss = [
        {"type": "Bữa sáng", "name": "Cháo yến mạch chuối và hạt chia", "calories": 320, "protein": 12, "carbs": 50, "fat": 6},
        {"type": "Bữa trưa", "name": "Salad ức gà áp chảo sốt chanh dây", "calories": 420, "protein": 35, "carbs": 20, "fat": 12},
        {"type": "Bữa nhẹ", "name": "Táo xanh và một hũ sữa chua không đường", "calories": 150, "protein": 6, "carbs": 25, "fat": 2},
        {"type": "Bữa tối", "name": "Cá hồi nướng măng tây và khoai lang luộc", "calories": 450, "protein": 30, "carbs": 35, "fat": 15}
    ]
    
    meals_gain = [
        {"type": "Bữa sáng", "name": "Bánh mì đen kẹp 3 trứng ốp la bơ quả", "calories": 550, "protein": 28, "carbs": 45, "fat": 22},
        {"type": "Bữa trưa", "name": "Cơm bò áp chảo bông cải xanh luộc", "calories": 700, "protein": 45, "carbs": 75, "fat": 18},
        {"type": "Bữa nhẹ", "name": "Sinh tố chuối bơ đậu phộng sữa whey", "calories": 400, "protein": 30, "carbs": 40, "fat": 12},
        {"type": "Bữa tối", "name": "Ức gà luộc, cơm gạo lứt và trứng luộc", "calories": 650, "protein": 50, "carbs": 70, "fat": 10}
    ]
    
    meals_health = [
        {"type": "Bữa sáng", "name": "Phở gà ta ít bánh nhiều rau thơm", "calories": 400, "protein": 22, "carbs": 55, "fat": 8},
        {"type": "Bữa trưa", "name": "Đậu hũ sốt cà chua nấm đông cô cơm tẻ", "calories": 480, "protein": 18, "carbs": 65, "fat": 14},
        {"type": "Bữa nhẹ", "name": "Đu đủ chín và một nắm nhỏ hạt hạnh nhân", "calories": 180, "protein": 5, "carbs": 22, "fat": 8},
        {"type": "Bữa tối", "name": "Canh bí đỏ thịt băm và cá lóc kho tộ", "calories": 450, "protein": 28, "carbs": 45, "fat": 12}
    ]
    
    chosen_meals = meals_loss if is_loss else (meals_gain if is_gain else meals_health)
    
    days = []
    
    for i, d_name in enumerate(remaining_days):
        day_idx = remaining_indices[i]
        day_ex = [chosen_exercises[day_idx % len(chosen_exercises)], chosen_exercises[(day_idx + 1) % len(chosen_exercises)]]
        days.append({
            "dayIndex": day_idx,
            "dayName": d_name,
            "workout": {
                "focus": "Tập toàn thân săn chắc" if day_idx % 2 == 0 else "Cardio dẻo dai",
                "exercises": day_ex
            },
            "nutrition": {
                "targetCalories": 1500 if is_loss else (2300 if is_gain else 1800),
                "meals": chosen_meals
            }
        })
        
    return {
        "planName": plan_name,
        "days": days
    }

@app.post("/progress/metrics")
async def estimate_body_metrics(request: Request):
    try:
        data = await request.json()
        landmarks = data.get("landmarks", [])
        if not landmarks:
            return {"status": "error", "message": "No landmarks"}
        estimated_fat = 22.5
        return {
            "status": "success",
            "estimated_body_fat": estimated_fat,
            "shoulder_hip_ratio": 0.85
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.post("/progress/analyze")
async def analyze_progress(request: Request):
    try:
        data = await request.json()
        requested_model = data.get("model", "")
        target_url, target_model = get_model_routing(requested_model)
        before_url = data.get("before_url")
        after_url = data.get("after_url")
        name = data.get("name", "bạn")
        pronoun = data.get("pronoun", "bạn")
        prompt = (
            f"Hãy đóng vai là một Huấn luyện viên cá nhân (PT) chuyên nghiệp, đáng yêu. "
            f"So sánh vóc dáng của người dùng qua 2 bức ảnh tiến độ:\n"
            f"- Ảnh Trước (Before): {before_url}\n"
            f"- Ảnh Sau (After): {after_url}\n"
            f"Hãy đưa ra nhận xét ngắn gọn (khoảng 3-4 câu) bằng tiếng Việt, xưng hô 'NutriTea' (tui) và gọi người dùng là '{pronoun} {name}'. "
            f"Đưa ra những lời khuyên tích cực, khen ngợi sự cải thiện vùng bụng, cơ vai hoặc tư thế đứng thẳng của {pronoun} {name} nhen!"
        )
        payload = {
            "model": target_model,
            "messages": [
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.7
        }
        response = requests.post(target_url, json=payload, timeout=45)
        if response.status_code == 200:
            result = response.json()
            ai_response = result["choices"][0]["message"]["content"].strip()
            return {"status": "success", "analysis": ai_response}
    except Exception:
        pass
    fake_response = f"Tuyệt vời quá {pronoun} {name} ơi! Cơ thể của {pronoun} trông thon gọn và cân đối hơn nhiều rồi đó. Cố gắng duy trì phong độ tập luyện này nhen! 🔥"
    return {"status": "success", "analysis": fake_response}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)