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

p = [sum(x) for x in transition_matrix]
print(p)

# c) What is the steady-state distribution? Compute it using methods learned in class.
# Answer, I will treat the 'quintiles' as income bins, that way it is possible for transitions between states
state_vector = np.array([12, 1, 11, 1, 21])
ITERATIONS_LIMIT = 1000
i = 0
while i < ITERATIONS_LIMIT:
    state_vector = state_vector.dot(transition_matrix)
    i += 1
state_vector /= sum(state_vector)
print('steady state vector:')
print(state_vector)
