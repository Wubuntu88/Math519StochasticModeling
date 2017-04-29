import numpy as np
import pandas as pd


# find the pre-event windows
def calculate_estimation_and_event_windows(_stock_date_data,
                                           _stock_price_data,
                                           _event_dates,
                                           _estimation_window,
                                           _event_window):
    indices = []
    for evt_date in _event_dates:
        idx = np.argwhere(_stock_date_data == evt_date)
        while len(idx) != 1:
            evt_date -= pd.Timedelta(days=1)
            evt_date = np.datetime64(evt_date)
            idx = np.argwhere(_stock_date_data == evt_date)
        assert len(idx) == 1
        indices.append(idx[0][0])

    # calculate the estimation windows
    estimation_windows = []
    event_windows = []
    for index in indices:
        est_window = _stock_price_data[index - _estimation_window:index]
        estimation_windows.append(est_window)
        evt_window = _stock_price_data[index + 1:index + 1 + _event_window]
        event_windows.append(evt_window)

    return estimation_windows, event_windows, np.array(indices)


def calculate_returns(x):
    assert len(x) > 1
    returns = []
    for i in range(1, len(x)):
        ret = (x[i] - x[i - 1]) / float(x[i])
        returns.append(ret)
    return returns


def calculate_bases(returns):
    """
    calculates the basis (aka average) for each stock returns in the estimation window
    :param returns: a list of np.arrays objects
    :return: a list of numbers, each element representing the average returns for each estimation window
    """
    return [np.mean(ret) for ret in returns]


def calculate_abnormal_returns(event_windows, bases):
    assert len(event_windows) == len(bases)
    abnormal_returns = []
    for i in range(0, len(bases)):
        event_window_values = event_windows[i]
        stock_returns = calculate_returns(event_window_values)  # represents stock returns for an estimation window
        basis = bases[i]  # represents the specific basis corresponding to the stock returns for an estimation window
        abnormal_return_for_est_win = stock_returns - basis
        abnormal_returns.append(abnormal_return_for_est_win)
    return abnormal_returns


def calculate_cumulative_abnormal_returns(abnormal_returns):
    """
    Calculates the sum of all of the abnormal returns
    :param abnormal_returns: a list of numpy arrays, each array being the abnormal returns for an event window
    :return: a list of ints, each int being the sum of the abnormal returns for an event window
    """
    return [np.sum(abnormal_ret) for abnormal_ret in abnormal_returns]


def calculate_cumulative_average_abnormal_returns(avg_abnormal_returns):
    return sum(avg_abnormal_returns) / float(len(avg_abnormal_returns))


def event_study(stock_date_data,
                stock_price_data,
                event_dates,
                estimation_window,
                event_window):
    assert isinstance(stock_date_data, np.ndarray)
    assert isinstance(stock_price_data, np.ndarray)
    assert isinstance(event_dates, np.ndarray)
    assert isinstance(estimation_window, int)
    assert estimation_window > 0
    assert isinstance(event_window, int)
    assert event_window > 0

    est_window_values, evt_window_values, indices = \
        calculate_estimation_and_event_windows(_stock_date_data=stock_date_data,
                                               _stock_price_data=stock_price_data,
                                               _event_dates=event_dates,
                                               _estimation_window=estimation_window,
                                               _event_window=event_window)

    returns = [calculate_returns(est_win) for est_win in est_window_values]
    bases = calculate_bases(returns=returns)
    abnormal_returns = calculate_abnormal_returns(event_windows=evt_window_values,
                                                  bases=bases)
    car = calculate_cumulative_abnormal_returns(abnormal_returns=abnormal_returns)
    car = np.array(car)
    caar = calculate_cumulative_average_abnormal_returns(avg_abnormal_returns=car)

    n = len(car)
    stdev = np.sqrt(np.sum(np.square(car-caar)) / n)
    t_statistic = np.sqrt(n) * (caar / stdev)

    return t_statistic, stdev, caar, list(car), abnormal_returns, bases
