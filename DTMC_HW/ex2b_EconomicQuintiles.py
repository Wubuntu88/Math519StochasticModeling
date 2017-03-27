#!/usr/bin/python

import numpy as np

transition_matrix = np.array(
    [0.42, 0.23, 0.19, 0.11, 0.06,  # first quintile to other quintiles transition probabilities
     0.25, 0.23, 0.24, 0.18, 0.10,  # second quintile...
     0.17, 0.24, 0.23, 0.17, 0.19,  # third quintile...
     0.08, 0.15, 0.19, 0.32, 0.26,  # fourth quintile...
     0.09, 0.15, 0.14, 0.23, 0.39]  # fifth quintile...
).reshape((5, 5))

print('Transition matrix:')
print(transition_matrix)

# b) If you are in the 5th quintile, what is the probability that
# your grandson will be in the 1st quintile?
start_state = 5
end_state = 1
print('\nThe following is a summation that shows the probability of a ' +
      '#{0:d} quintile individual having a #{1:d} quintile grandchild'.format(start_state, end_state))
probabilities = []
for k in range(0, transition_matrix.shape[0]):
    probabilities.append(transition_matrix[start_state - 1][k] * transition_matrix[k][end_state - 1])
    print('P({0:d}->{1:d})*P({2:d}->{3:d}) = {4:.4f}'.format(start_state, k, k, end_state, probabilities[-1]))
sum_of_probabilities = sum(probabilities)
print('Sum of Probabilities:')
print('P({0:d}->?->{1:d}) = {2:.4f}'.format(start_state, end_state, sum_of_probabilities))
