
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
import matplotlib.patches as mpatches


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

ford_df_over_1_mil = ford_df.loc[df['Estimated Units'] > 1000000.0]


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


# In[16]:

recalls_by_units_df_after_1995 = recalls_by_units_df.loc[recalls_by_units_df['Recall Notification Date'] > date_split_value]


# In[17]:

recalls_by_unit_after_1995_unique = recalls_by_units_df_after_1995.drop_duplicates()


# In[18]:

ford_stock_data_types = {
    'Date': str,
    'Price': float
}
ford_stock = pd.read_csv('zstock_data_clean/ford_stock.txt', sep='\t', parse_dates=['Date'])


# In[19]:

ford_stock_after_1995 = ford_stock.loc[ford_stock['Date'] > date_split_value]


# In[20]:

plt.plot(list(ford_stock_after_1995['Date']), list(ford_stock_after_1995['Price']))
#plt.scatter(list(recalls_by_unit_after_1995_unique['Recall Notification Date']), [25 for x in range(0, len(recalls_by_unit_after_1995_unique))])
#for i in range(0, len(recalls_by_unit_after_1995_unique))
#    plt.plot([, ])
my_dates_list = list(recalls_by_unit_after_1995_unique['Recall Notification Date'])
plt.vlines(x=my_dates_list, ymin=[0 for x in range(0, len(my_dates_list))], ymax=[25 for x in range(0, len(my_dates_list))])
plt.title('Ford Stock', fontsize=20)
plt.xlabel('Time', fontsize=16)
plt.ylabel('Stock Price', fontsize=16)
black_patch = mpatches.Patch(color='black', label='recalls > 1 million units')
plt.legend(handles=[black_patch],
           loc='upper right')
#plt.show()


# In[21]:

type(ford_stock_after_1995['Date'][5707])


# In[22]:

type(recalls_by_unit_after_1995_unique['Recall Notification Date'][4605])


# In[50]:

ford_stock_after_1995_reset_indices = ford_stock_after_1995.reset_index()
ford_stock_after_1995_reset_indices.drop('index', axis=1, inplace=True)


# In[51]:

# now we will conduct the event study
dates_arr = np.array(ford_stock_after_1995_reset_indices['Date'])
prices_arr = np.array(ford_stock_after_1995_reset_indices['Price'])
recalls_dates_arr = np.array(recalls_by_unit_after_1995_unique['Recall Notification Date'])


# In[52]:

len(dates_arr)


# In[53]:

len(recalls_dates_arr)


# In[54]:

d = recalls_dates_arr[1]
print(d)
d = d - pd.Timedelta(days=3)
d = np.datetime64(d)
np.argwhere(dates_arr == d)
print(d)
print(dates_arr[1020])


# In[55]:

estimation_window = 100
event_window = 100


# In[56]:

import event_study.event_study as evt


# In[57]:

t_statistic, stdev, caar, car, abnormal_returns, bases = evt.event_study(stock_date_data=dates_arr,
                                                                           stock_price_data=prices_arr,
                                                                           event_dates=recalls_dates_arr,
                                                                           estimation_window=estimation_window,
                                                                           event_window=event_window)
print("t stat:", t_statistic)
print("stdev: ", stdev)




est_windows, evt_windows, indices = evt.calculate_estimation_and_event_windows(_stock_date_data=dates_arr,
                                                       _stock_price_data=prices_arr,
                                                       _event_dates=recalls_dates_arr,
                                                       _estimation_window=estimation_window,
                                                       _event_window=event_window)




num_cols = 3
num_rows = 2
f, axarr = plt.subplots(num_rows, num_cols)
ith_period = 0
for col in range(0, 3):
    for row in range(0, 2):
        x1 = []
        x1.extend(est_windows[ith_period])
        x1.append(prices_arr[indices[ith_period]])
        x1.extend(evt_windows[ith_period])
        axarr[row, col].plot(x1, c='burlywood')
        axarr[row, col].vlines(x=len(x1)/2, ymin=min(x1), ymax=max(x1))
        ith_period += 1
#plt.show()
