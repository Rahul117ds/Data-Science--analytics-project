#!/usr/bin/env python
# coding: utf-8

# In[1]:


import numpy as np
import pandas as pd
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.metrics import r2_score, mean_squared_error
import numpy as np


# In[8]:


df = pd.read_excel("C:\\Users\\PRANAY KUMAR\\Downloads\\uber_rides_data.xlsx")


# In[9]:


df


# In[15]:


df.isna().sum()


# In[19]:


df["fare_amount"].mean().sum()


# In[21]:


df["fare_amount"].max()


# In[25]:


df['pickup_datetime'] = pd.to_datetime(df['pickup_datetime'])


# In[26]:


rides_2014 = df[df['pickup_datetime'].dt.year == 2014]
total_rides_2014 = len(rides_2014)


# In[27]:


print(f"Total rides recorded in 2014: {total_rides_2014}")


# In[28]:


rides_q1_2014 = df[(df['pickup_datetime'].dt.year == 2014) & (df['pickup_datetime'].dt.quarter == 1)]
total_rides_q1_2014 = len(rides_q1_2014)


# In[29]:


print(total_rides_q1_2014)


# In[30]:


rides_september_2010 = df[(df['pickup_datetime'].dt.year == 2010) & (df['pickup_datetime'].dt.month == 9)]
rides_by_day_of_week = rides_september_2010.groupby(rides_september_2010['pickup_datetime'].dt.day_name()).size()
max_day = rides_by_day_of_week.idxmax()
max_rides = rides_by_day_of_week.max()


# In[32]:


print(f"On {max_day}, in September 2010, the maximum rides were recorded: {max_rides} rides.")


# In[37]:


df.columns


# In[38]:


X = df[['passenger_count', 'pickup_datetime']]
y = df['fare_amount']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

linear_reg = LinearRegression()
random_forest_reg = RandomForestRegressor()
gradient_boosting_reg = GradientBoostingRegressor()
adjusted_r2_values = {}

for model, model_name in [(linear_reg, 'Linear Regression'), (random_forest_reg, 'Random Forest Regression'), (gradient_boosting_reg, 'Gradient Boosting Regression')]:
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    
    r2 = r2_score(y_test, y_pred)
    n = X_test.shape[0]
    p = X_test.shape[1]
    adjusted_r2 = 1 - (1 - r2) * ((n - 1) / (n - p - 1))
    adjusted_r2_values[model_name] = adjusted_r2
min_adj_r2_model = min(adjusted_r2_values, key=adjusted_r2_values.get)
min_adj_r2_value = adjusted_r2_values[min_adj_r2_model]

print(f"The algorithm with the least adjusted R-squared value is {min_adj_r2_model} with an adjusted R-squared value of {min_adj_r2_value:.4f}.")


# In[ ]:




