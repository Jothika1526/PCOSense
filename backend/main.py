from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
from motor.motor_asyncio import AsyncIOMotorClient
import shutil
import os
from datetime import datetime

# --- Configuration ---
# IMPORTANT: Replace with your MongoDB connection string
# Example for local: "mongodb://localhost:27017/"
# Example for Atlas: "mongodb+srv://<username>:<password>@<cluster-url>/<database-name>?retryWrites=true&w=majority"
MONGO_DETAILS = "mongodb+srv://jothika00015:mongodbpass@pcos-cluster.s4ihzo5.mongodb.net/?retryWrites=true&w=majority&appName=pcos-cluster"

DATABASE_NAME = "pcos_food_data" # Your database name
COLLECTION_NAME = "food_items" # Collection to store food data

# Directory to save uploaded images (for local storage example)
# In production, consider cloud storage like AWS S3 or Google Cloud Storage
UPLOAD_DIR = "uploaded_food_images"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# --- FastAPI App Initialization ---
app = FastAPI()

# --- Database Connection ---
class MongoDB:
    client: AsyncIOMotorClient = None
    database = None

    def connect(self):
        self.client = AsyncIOMotorClient(MONGO_DETAILS)
        self.database = self.client[DATABASE_NAME]
        print("Connected to MongoDB!")

    def close(self):
        self.client.close()
        print("Disconnected from MongoDB.")

mongo_db = MongoDB()

@app.on_event("startup")
async def startup_db_client():
    mongo_db.connect()

@app.on_event("shutdown")
async def shutdown_db_client():
    mongo_db.close()

# --- Placeholder for your Food Analysis Function ---
def analyze_food_image(image_path: str, dish_name: str) -> str:
    """
    This function simulates food analysis. In a real application,
    you would integrate a machine learning model (e.g., using TensorFlow/PyTorch
    for image classification), an external food API, or a more complex logic here.
    """
    print(f"Analyzing image: {image_path} for dish: {dish_name}")

    # Simple rule-based simulation for demonstration
    dish_name_lower = dish_name.lower()
    if "pizza" in dish_name_lower:
        return "This looks like a high-calorie comfort food, consider portion control."
    elif "salad" in dish_name_lower:
        return "Great choice! This appears to be a healthy and fibrous option."
    elif "chicken" in dish_name_lower and "biryani" in dish_name_lower:
        return "A rich, flavorful dish. Enjoy in moderation, especially if managing calorie intake."
    elif "eggs" in dish_name_lower or "paneer" in dish_name_lower:
        return "Good source of protein. Important for balanced nutrition."
    else:
        return "Food analysis complete. More details would require a sophisticated AI model!"

# --- FastAPI Endpoint ---
@app.post("/upload_food_data/")
async def upload_food_data(
    file: UploadFile = File(...),
    dish_name: str = Form(...)
):
    """
    Receives a food image and dish name, saves the image,
    stores the data in MongoDB, and returns an analysis answer.
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=400,
            detail="Uploaded file must be an image."
        )

    # Sanitize filename to prevent directory traversal issues
    safe_filename = os.path.basename(file.filename)
    # Add a timestamp to ensure uniqueness and prevent overwrites
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    unique_filename = f"{timestamp}_{safe_filename}"
    file_location = os.path.join(UPLOAD_DIR, unique_filename)

    try:
        # Save the uploaded image locally
        with open(file_location, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        print(f"Image saved to: {file_location}")

        # Call your food analysis function
        analysis_result = analyze_food_image(file_location, dish_name)

        # Store data in MongoDB
        food_collection = mongo_db.database[COLLECTION_NAME]
        food_item = {
            "dish_name": dish_name,
            "image_filename": unique_filename, # Store unique filename
            "uploaded_at": datetime.now(),
            "analysis_result": analysis_result # Store the result of current analysis
            # Add more fields here as your model evolves, e.g., 'classification_labels', 'nutrition_info'
        }
        await food_collection.insert_one(food_item)
        print("Data stored in MongoDB.")

        return JSONResponse(
            status_code=200,
            content={
                "message": "Food data uploaded and analyzed successfully.",
                "dish_name": dish_name,
                "analysis_answer": analysis_result,
                "image_filename_stored": unique_filename
            }
        )
    except Exception as e:
        print(f"Error processing upload: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to process food data: {str(e)}"
        )
    finally:
        # Ensure the uploaded file stream is closed
        file.file.close()

# Example: A simple endpoint to list stored food items (for testing/viewing)
@app.get("/list_food_items/")
async def list_food_items():
    food_collection = mongo_db.database[COLLECTION_NAME]
    food_items = []
    async for item in food_collection.find({}, {"_id": 0}).sort("uploaded_at", -1).limit(50):
        # Convert datetime objects to string for JSON serialization
        if 'uploaded_at' in item:
            item['uploaded_at'] = item['uploaded_at'].isoformat()
        food_items.append(item)
    return JSONResponse(content=food_items)