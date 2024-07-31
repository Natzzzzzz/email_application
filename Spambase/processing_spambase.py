from deep_translator import GoogleTranslator
import re
import numpy as np
from collections import Counter
from tensorflow.keras.models import load_model
import joblib

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

def process_email(email):
    
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
    
email_text_vi = """
Chào bạn,
Bạn đã trúng giải thưởng lớn từ chương trình khuyến mãi của chúng tôi! Để nhận phần thưởng, bạn chỉ cần nhấp vào đường link dưới đây và điền thông tin cá nhân. Đây là cơ hội tuyệt vời để sở hữu những phần quà giá trị như iPhone, laptop và nhiều hơn thế nữa. Đừng bỏ lỡ cơ hội này, hãy nhanh tay đăng ký ngay hôm nay để trở thành người may mắn nhất. Mọi thắc mắc xin liên hệ với chúng tôi qua email hoặc số điện thoại hotline. Chúc bạn may mắn!
"""

features = process_email(process_email_translate(email_text_vi))

features = np.array(features).reshape(1, -1) 
features = scaler.transform(features) 

predictions = model.predict(features)
predicted_class = np.argmax(predictions, axis=1)

def get_result_spambase():
    return 'Spam' if predicted_class[0] == 1 else 'Not Spam'

print(get_result_spambase())