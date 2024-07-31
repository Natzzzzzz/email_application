import re
import joblib
import tensorflow as tf
from tensorflow.keras.models import load_model
from deep_translator import GoogleTranslator

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

def clean_text(text):
    text = re.sub(r'<.*?>', '', text)
    text = re.sub(r'[^\w\s]', '', text)
    text = text.lower()
    return text

def process_email(email_text):
    cleaned_text = clean_text(email_text)
    
    vectorizer = joblib.load('vectorizer_phishing.pkl')
    
    email_bow = vectorizer.transform([cleaned_text])
    
    model = load_model('model_phishing.h5')
    
    prediction = model.predict(email_bow.toarray())
    predicted_class = prediction.argmax(axis=-1)  
    
    return 'Phishing' if predicted_class[0] == 1 else 'Not Phishing'

email_text_vi = """

Hello I am your hot lil horny toy.
    I am the one you dream About,
    I am a very open minded person,
    Love to talk about and any subject.
    Fantasy is my way of life, 
    Ultimate in sex play.     Ummmmmmmmmmmmmm
     I am Wet and ready for you.     It is not your looks but your imagination that matters most,
     With My sexy voice I can make your dream come true...
  
     Hurry Up! call me let me Cummmmm for you..........................
TOLL-FREE:             1-877-451-TEEN (1-877-451-8336)For phone billing:     1-900-993-2582
-- 
_______________________________________________
Sign-up for your own FREE Personalized E-mail at Mail.com
http://www.mail.com/?sr=signup

"""

print(process_email(process_email_translate(email_text_vi)))