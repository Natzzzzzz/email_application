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
    
    vectorizer = joblib.load('vectorizer_spam_assassin.pkl')
    
    email_bow = vectorizer.transform([cleaned_text])
    
    model = load_model('model_spam_assassin.h5')
    
    prediction = model.predict(email_bow.toarray())
    predicted_class = prediction.argmax(axis=-1)  
    
    return 'Spam' if predicted_class[0] == 1 else 'Not Spam'

email_text_vi = """

Received: from dallas.net (ultra1.dallas.net [204.215.60.15]) by linux.midrange.com (8.11.6/8.11.6) with ESMTP id g6OBc3e03139 for <gibbs@midrange.com>; Wed, 24 Jul 2002 06:38:03 -0500 Received: from larry.catalog.com (larry.catalog.com [209.217.36.10]) by dallas.net (8.12.2/8.12.2) with ESMTP id g6OBV7mv005342; Wed, 24 Jul 2002 06:31:08 -0500 (CDT) Received: (from spiritweb@localhost) by larry.catalog.com (8.12.0.Beta19/8.12.0.Beta19) id g6OBUJcd019533; Wed, 24 Jul 2002 06:30:19 -0500 (CDT) Date: Wed, 24 Jul 2002 06:30:19 -0500 (CDT) Message-Id: <200207241130.g6OBUJcd019533@larry.catalog.com> To: gibbs@koalas.com, gibbs@mcs.com, gibbs@mercury.mcs.net, gibbs@midrange.com, gibbs@nternet.com, gibbs@rcn.com, gibbs@sprintmail.com, gibbs_donna@msn.com, gibbs_household@bigpond.com, gibbs_raetz@msn.com From: YourPeach21@hotmail.com () Subject: Limited Time Offer For A FREE Membership! X-Status: X-Keywords: Below is the result of your feedback form. It was submitted by (YourPeach21@hotmail.com) on Wednesday, July 24, 2002 at 06:30:19 --------------------------------------------------------------------------- :: For a limited time you can get a 100% FREE membership to the best sites on the internet. No telling how long this limited time offer will last <a href="http://rd.yahoo.com/dir/?http://members.lycos.co.uk/yourselected/winner.htm">Act Fast!</a>If You Would Like To Be Removed Then <a href="mailto:remove_me123@hotmail.com">remove</a> ---------------------------------------------------------------------------

"""

print(process_email(process_email_translate(email_text_vi)))
