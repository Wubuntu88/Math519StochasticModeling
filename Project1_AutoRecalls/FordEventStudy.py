
# coding: utf-8

# In[1]:

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import re
import seaborn as sns
sns.set(style="darkgrid")
from scipy import stats


# In[2]:

data_types = {'Recall Notification Date': str}
df = pd.read_csv("database.csv", dtype=data_types)


# In[3]:

df.dtypes


# In[4]:

ford_aliases = {
    'FORD MOTOR COMPANY',
    'FORD MOTOR COMPANY test adw as',
    'FORD MTR CO-OVERSEAS',
    'Ford Motor Company'
}


# In[5]:

ford_df = df.loc[df['Vehicle Manufacturer'].isin(ford_aliases)]


# In[6]:

ford_df_over_1_mil = ford_df.loc[df['Estimated Units'] > 2000000.0]


# In[7]:

len(ford_df_over_1_mil)


# In[8]:

ford_df_filtered = ford_df_over_1_mil.dropna(subset=['Recall Notification Date'])


# In[9]:

ford_df_filtered_with_date = ford_df_filtered['Recall Notification Date'].apply(lambda x:pd.datetime.strptime(x, '%Y%m%d'))


# In[10]:

type(ford_df_filtered['Estimated Units'])


# In[11]:

date_split_value = pd.datetime(1995, 1, 1) # ignore values before 1995


# In[12]:

recalls_by_units_df = pd.DataFrame({
        'Recall Notification Date': ford_df_filtered_with_date,
        'Estimated Units': ford_df_filtered['Estimated Units']
})


# In[13]:

recalls_by_units_df_after_1995 = recalls_by_units_df.loc[recalls_by_units_df['Recall Notification Date'] > date_split_value]


# In[14]:

recalls_by_unit_after_1995_unique = recalls_by_units_df_after_1995.drop_duplicates()


# In[15]:

ford_stock_data_types = {
    'Date': str,
    'Price': float
}
ford_stock = pd.read_csv('zstock_data_clean/ford_stock.txt', sep='\t', parse_dates=['Date'])


# In[16]:

ford_stock_after_1995 = ford_stock.loc[ford_stock['Date'] > pd.datetime(1995, 1, 1)]


# In[17]:

#plt.plot(list(ford_stock_after_1995['Date']), list(ford_stock_after_1995['Price']))
#plt.scatter(list(recalls_by_unit_after_1995_unique['Recall Notification Date']), [25 for x in range(0, len(recalls_by_unit_after_1995_unique))])
#for i in range(0, len(recalls_by_unit_after_1995_unique))
#    plt.plot([, ])
my_dates_list = list(recalls_by_unit_after_1995_unique['Recall Notification Date'])
#plt.vlines(x=my_dates_list, ymin=[0 for x in range(0, len(my_dates_list))], ymax=[0 for x in range(0, len(my_dates_list))])
#plt.show()


# In[18]:

type(ford_stock_after_1995['Date'][5707])


# In[19]:

type(recalls_by_unit_after_1995_unique['Recall Notification Date'][4605])


# In[20]:

ford_stock_after_1995_reset_indices = ford_stock_after_1995.reset_index()
ford_stock_after_1995_reset_indices.drop('index', axis=1, inplace=True)


# In[21]:

z2001 = recalls_by_unit_after_1995_unique['Recall Notification Date'][4605]


# In[71]:

z2001
print("z2001:", z2001)
print("z2001 - 1 day:", z2001 - pd.Timedelta(days=1))




# In[23]:

idx_value = ford_stock_after_1995_reset_indices['Date'][ford_stock_after_1995_reset_indices['Date'] == z2001].index[0]


# In[24]:

idx_value


# In[25]:

first_index = idx_value - 100
last_index = idx_value + 101
z2001_ford_stock_df = ford_stock_after_1995_reset_indices.iloc[first_index:last_index]


# In[26]:

#plt.plot(list(z2001_ford_stock_df['Date']), list(z2001_ford_stock_df['Price']))
#plt.vlines(x=z2001, ymin=10, ymax=22)
#plt.show()


# In[27]:

len(z2001_ford_stock_df)


# In[28]:

def find_returns(x):
    assert len(x) > 1
    returns = []
    for i in range(1, len(x)):
        ret = (x[i] - x[i-1]) / float(x[i])
        returns.append(ret)
    return returns


# In[29]:

#find daily returns
prev_100_days = list(z2001_ford_stock_df['Price'][:100])
returns = find_returns(prev_100_days)
basis = sum(returns) / len(returns)
#plt.plot(returns)
#plt.hlines(y=basis, xmin=0, xmax=len(returns))
#plt.show()
#print("basis:", basis)


# In[30]:

subsequent_100_days = list(z2001_ford_stock_df['Price'][101:])
subs_100_days_returns = find_returns(subsequent_100_days)
abnormal_returns = [x-basis for x in subs_100_days_returns]
#plt.plot(abnormal_returns)
#plt.show()


# In[31]:

CAR = sum(abnormal_returns)
CAR


# In[32]:

# now we will conduct the event study
dates_arr = np.array(ford_stock_after_1995_reset_indices['Date'])
prices_arr = np.array(ford_stock_after_1995_reset_indices['Price'])
recalls_dates_arr = np.array(recalls_by_unit_after_1995_unique['Recall Notification Date'])


# In[53]:

dates_arr


# In[52]:

recalls_dates_arr


# In[83]:

d = recalls_dates_arr[1]
len(np.argwhere(dates_arr == d))


# In[33]:

estimation_window = 100
event_window = 100


# In[77]:

import event_study.event_study as evt


# In[84]:

t_statistic, stdev, caar, car, abnormal_returns, bases = evt.event_study(stock_date_data=dates_arr,
                                                           stock_price_data=prices_arr,
                                                           event_dates=recalls_dates_arr,
                                                           estimation_window=estimation_window,
                                                           event_window=event_window)


print("t stat:", t_statistic)
print("stdev: ", stdev)
