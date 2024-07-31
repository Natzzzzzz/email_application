import pandas as pd
import re
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.preprocessing import LabelEncoder
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.callbacks import EarlyStopping
import joblib

data = pd.read_csv('phishing_email.csv')
data = data.head(10000)

def clean_text(text):
    text = re.sub(r'<.*?>', '', text) 
    text = re.sub(r'[^\w\s]', '', text) 
    text = text.lower() 
    return text

data['Email Text'] = data['Email Text'].fillna('')

data['Email Text'] = data['Email Text'].apply(clean_text)

data['Email Type'] = data['Email Type'].apply(lambda x: 1 if x == 'Phishing Email' else 0)

X_train, X_test, y_train, y_test = train_test_split(data['Email Text'], data['Email Type'], test_size=0.3, random_state=42)

vectorizer = CountVectorizer()
X_train_bow = vectorizer.fit_transform(X_train)
X_test_bow = vectorizer.transform(X_test)

model = keras.Sequential([
    layers.Input(shape=(X_train_bow.shape[1],)),
    layers.Dense(40, activation='relu', kernel_regularizer=keras.regularizers.l2(0.01)),  
    layers.Dense(32, activation='relu', kernel_regularizer=keras.regularizers.l2(0.01)), 
    layers.Dense(16, activation='relu', kernel_regularizer=keras.regularizers.l2(0.01)),  
    layers.Dense(2, activation='softmax')
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

early_stopping = EarlyStopping(monitor='val_loss', patience=3, restore_best_weights=True)

model.fit(X_train_bow.toarray(), y_train, epochs=10, batch_size=32, validation_split=0.2, callbacks=[early_stopping])

loss, accuracy = model.evaluate(X_test_bow.toarray(), y_test)
print(f'Loss: {loss}, Accuracy: {accuracy}')

model.save('model_phishing.h5')
joblib.dump(vectorizer, 'vectorizer_phishing.pkl')