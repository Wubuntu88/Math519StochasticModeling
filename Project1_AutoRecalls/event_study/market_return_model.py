import numpy as np


def calculate_abnormal_returns(list_of_stock_price_arrays, list_of_market_index_arrays):
    """
    Calculates the abnormal returns corresponding to each stock price array.
    Abnormal returns are calculated as follows:
    AR(i,t) = R(i,t) - R(M,t)
    Where i is the firm and t is the event date, and M signifies the returns of a market index.
    The abnormal returns (AR) is an array, as are R(i,t) and R(M,t).
    This function takes as input a list of R(i,t) and a list of R(M,t), kind of like parallel arrays.
    :param list_of_stock_price_arrays: a list of np.array objects.  Each array contains a contiguous list
    of stock prices for one company.  Each array also corresponds to an event.
    :param list_of_market_index_arrays: a list of np.array objects.  Each array contains a contiguous list
    of market index values (i.e. from the S&P 500).
    :return: a list of arrays corresponding to the abnormal returns for each event.
    """
    assert len(list_of_stock_price_arrays) == len(list_of_market_index_arrays)
    abnormal_returns = []
    for t in range(0, len(list_of_stock_price_arrays)):
        stock_price_array_at_time_t = list_of_stock_price_arrays[t]
        market_index_price_array_at_time_t = list_of_market_index_arrays[t]
        abnormal_return = stock_price_array_at_time_t - market_index_price_array_at_time_t
        abnormal_returns.append(abnormal_return)
    return abnormal_returns


def calculate_returns(x):
    assert len(x) > 1
    returns = []
    for i in range(1, len(x)):
        ret = (x[i] - x[i - 1]) / float(x[i])
        returns.append(ret)
    return returns


def calculate_cumulative_abnormal_returns(abnormal_returns):
    """
    Calculates the sum of all of the abnormal returns
    :param abnormal_returns: a list of numpy arrays, each array being the abnormal returns for an event window
    :return: a list of ints, each int being the sum of the abnormal returns for an event window
    """
    return [np.sum(abnormal_ret) for abnormal_ret in abnormal_returns]


def calculate_cumulative_average_abnormal_returns(avg_abnormal_returns):
    return sum(avg_abnormal_returns) / float(len(avg_abnormal_returns))

