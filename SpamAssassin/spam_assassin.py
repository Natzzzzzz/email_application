import pandas as pd
import re
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.callbacks import EarlyStopping
import joblib
from tensorflow.keras import regularizers

data = pd.read_csv('spam_assassin.csv') 

def clean_text(text):
    text = re.sub(r'<.*?>', '', text) 
    text = re.sub(r'[^\w\s]', '', text) 
    text = text.lower() 
    return text

data['text'] = data['text'].apply(clean_text)

X_train, X_test, y_train, y_test = train_test_split(data['text'], data['target'], test_size=0.3, random_state=42)

vectorizer = CountVectorizer()
X_train_bow = vectorizer.fit_transform(X_train)
X_test_bow = vectorizer.transform(X_test)

y_train = keras.utils.to_categorical(y_train, num_classes=2)
y_test = keras.utils.to_categorical(y_test, num_classes=2)

model = keras.Sequential([
    layers.Dense(40, activation='relu', input_shape=(X_train_bow.shape[1],), 
                 kernel_regularizer=regularizers.l2(0.01)), 
    layers.Dense(32, activation='relu', 
                 kernel_regularizer=regularizers.l2(0.01)),  
    layers.Dense(16, activation='relu', 
                 kernel_regularizer=regularizers.l2(0.01)),  
    layers.Dense(2, activation='softmax') 
])

model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

early_stopping = EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)

model.fit(X_train_bow.toarray(), y_train, epochs=10, batch_size=32, validation_split=0.2, callbacks=[early_stopping])

loss, accuracy = model.evaluate(X_test_bow.toarray(), y_test)
print(f'Loss: {loss}, Accuracy: {accuracy}')

model.save('model_spam_assassin.h5')
joblib.dump(vectorizer, 'vectorizer_spam_assassin.pkl')