import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.utils import to_categorical
from tensorflow.keras.callbacks import EarlyStopping
from tensorflow.keras.regularizers import l2
import joblib

data = pd.read_csv('spambase.csv')
X = data.iloc[:, :-1].values  
y = data.iloc[:, -1].values  

scaler = StandardScaler()
X = scaler.fit_transform(X)

y = to_categorical(y)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

model = Sequential()
model.add(Dense(57, input_dim=X.shape[1], activation='relu', kernel_regularizer=l2(0.001)))  
model.add(Dense(32, activation='relu', kernel_regularizer=l2(0.001)))  
model.add(Dense(16, activation='relu', kernel_regularizer=l2(0.001))) 
model.add(Dense(y.shape[1], activation='softmax')) 

model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

early_stopping = EarlyStopping(monitor='val_loss', patience=3, restore_best_weights=True)
history = model.fit(X_train, y_train, epochs=10, batch_size=32, validation_split=0.2, callbacks=[early_stopping])

loss, accuracy = model.evaluate(X_test, y_test)
print(f'Loss: {loss}, Accuracy: {accuracy}')

model.save('model_spambase.h5')
joblib.dump(scaler, 'scaler_spambase.pkl')