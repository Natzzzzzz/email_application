from deep_translator import GoogleTranslator
import re
import numpy as np
from collections import Counter
from tensorflow.keras.models import load_model
import joblib
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class EmailRequest(BaseModel):
    email: str

scaler = joblib.load('scaler_spambase.pkl')
model = load_model('model_spambase.h5')

keywords = ["make", "address", "all", "3d", "our", "over", "remove", "internet", "order", "mail", "receive", "will",
            "people", "report", "addresses", "free", "business", "email", "you", "credit", "your", "font", "000",
            "money", "hp", "hpl", "george", "650", "lab", "labs", "telnet", "857", "data", "415", "85", "technology",
            "1999", "parts", "pm", "direct", "cs", "meeting", "original", "project", "re", "edu", "table", "conference"]
special_chars = [';', '(', '[', '!', '$', '#']

def translate_text(text, dest='en'):
    translator = GoogleTranslator(source='auto', target=dest)
    if len(text) > 5000:
        translated_text = []
        for i in range(0, len(text), 5000):
            translated_text.append(translator.translate(text[i:i+5000]))
        return ''.join(translated_text)
    return translator.translate(text)

def process_email_translate(email_text):
    email_text_en = translate_text(email_text, dest='en')
    return email_text_en

def process_email_spambase(email):
    
    capital_letters = re.findall(r'[A-Z]+', email)
    if capital_letters:
        capital_lengths = [len(cap) for cap in capital_letters]
        capital_run_length_average = np.mean(capital_lengths)
        capital_run_length_longest = np.max(capital_lengths)
        capital_run_length_total = np.sum(capital_lengths)
    else:
        capital_run_length_average = 0
        capital_run_length_longest = 0
        capital_run_length_total = 0
    email = email.lower()
    
    email = re.sub(r'<[^<>]+>', ' ', email)
    
    email = re.sub(r'[0-9]+', ' ', email)
    email = re.sub(r'(http|https)://[^\s]*', 'httpaddr', email)
    email = re.sub(r'[^\s]+@[^\s]+', 'emailaddr', email)
    email = re.sub(r'[$]+', 'dollar', email)
    
    words = re.findall(r'\b\w+\b', email)
    word_counts = Counter(words)
    keyword_freqs = [(word_counts.get(keyword, 0) * 100) / len(words) for keyword in keywords]
    
    special_char_counts = Counter(email)
    special_char_freqs = [special_char_counts.get(char, 0) / len(email) for char in special_chars]
    
    feature_vector = keyword_freqs + special_char_freqs + [capital_run_length_average, capital_run_length_longest, capital_run_length_total]
    
    return feature_vector

def get_result_spambase(email: str):
    email_text_vi = email
    features = process_email_spambase(process_email_translate(email_text_vi))
    features = np.array(features).reshape(1, -1) 
    features = scaler.transform(features) 
    predictions = model.predict(features)
    predicted_class = np.argmax(predictions, axis=1)
    return 'Spam' if predicted_class[0] == 1 else 'Not Spam'

def clean_text(text):
    text = re.sub(r'<.*?>', '', text)
    text = re.sub(r'[^\w\s]', '', text)
    text = text.lower()
    return text

def process_email_spam_assassin(email: str):
    email_text = email
    cleaned_text = clean_text(email_text)
    
    vectorizer = joblib.load('vectorizer_spam_assassin.pkl')
    
    email_bow = vectorizer.transform([cleaned_text])
    
    model = load_model('model_spam_assassin.h5')
    
    prediction = model.predict(email_bow.toarray())
    predicted_class = prediction.argmax(axis=-1)  
    
    return 'Spam' if predicted_class[0] == 1 else 'Not Spam'

def process_email_phishing(email: str):
    email_text = email
    cleaned_text = clean_text(email_text)
    
    vectorizer = joblib.load('vectorizer_phishing.pkl')
    
    email_bow = vectorizer.transform([cleaned_text])
    
    model = load_model('model_phishing.h5')
    
    prediction = model.predict(email_bow.toarray())
    predicted_class = prediction.argmax(axis=-1)  
    
    return 'Phishing' if predicted_class[0] == 1 else 'Not Phishing'

@app.post("/predict")
def predict_spam(input: EmailRequest):
    result_spambase = get_result_spambase(input.email)
    result_spam_assassin = process_email_spam_assassin(process_email_translate(input.email))
    result_phishing = process_email_phishing(process_email_translate(input.email))
    if result_spambase == "Not Spam" and result_spam_assassin == "Not Spam" and result_phishing == "Not Phishing":
        return "Normal"
    elif result_spambase == "Not Spam" and result_spam_assassin == "Not Spam" and result_phishing == "Phishing":
        return "Phishing"
    elif result_spambase == "Spam" or result_spam_assassin == "Spam" and result_phishing == "Not Phishing":
        return "Spam"
    elif result_spambase == "Spam" or result_spam_assassin == "Spam" and result_phishing == "Phishing":
        return "Spam and Phishing"
    return result_spambase + result_spam_assassin + result_phishing

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)