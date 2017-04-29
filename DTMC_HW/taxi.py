#!/usr/bin/python

import numpy as np

transition_matrix = np.array(
    [0.6, 0.4,  # From A to A,B
     0.3, 0.7]  # From B to A,B
).reshape((2, 2))

print('Transition matrix:')
print(transition_matrix)


state_vector = np.array([1, 1])
ITERATIONS_LIMIT = 100
i = 0
while i < ITERATIONS_LIMIT:
    state_vector = state_vector.dot(transition_matrix)
    i += 1
state_vector /= sum(state_vector)
print('steady state vector:')
print(state_vector)

taxi_zone_cost_A_to_A = 6
taxi_zone_cost_A_to_B = 12
taxi_zone_cost_B_to_B = 8
taxi_zone_cost_B_to_A = 12

expected_profit_from_zone_A = transition_matrix[0][0] * taxi_zone_cost_A_to_A + \
                                transition_matrix[0][1] * taxi_zone_cost_A_to_B

expected_profit_from_zone_B = transition_matrix[1][0] * taxi_zone_cost_B_to_B + \
                                transition_matrix[1][1] * taxi_zone_cost_B_to_A

print("expected profit from zone A:", expected_profit_from_zone_A)
print("expected profit from zone B:", expected_profit_from_zone_B)
