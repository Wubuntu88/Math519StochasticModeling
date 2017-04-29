#!/usr/bin/python
import numpy as np
import event_study.event_study as evt

stock = np.array(np.arange(0, 50))
events = np.array([8, 16])
est_win = 5
evt_win = 5
'''
t = evt.calculate_estimation_and_event_windows(_stock_data=stock,
                                               _event_dates=events,
                                               _estimation_window=est_win,
                                               _event_window=evt_win)
'''
r = evt.event_study(stock_date_data=stock, event_dates=events, estimation_window=est_win, event_window=evt_win)

print(r)
