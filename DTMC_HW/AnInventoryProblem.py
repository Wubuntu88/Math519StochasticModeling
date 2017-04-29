#!/usr/bin/python

import numpy as np

transition_matrix = np.array(
    [
        5/8, 1/8, 1/8, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        4/8, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        3/8, 1/8, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0,
        2/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 0.0, 0.0,
        1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 0.0,
        0.0, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0,
        0.0, 0.0, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 0.0,
        0.0, 0.0, 0.0, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8,
        0.0, 0.0, 0.0, 0.0, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 2/8,
        0.0, 0.0, 0.0, 0.0, 0.0, 1/8, 1/8, 1/8, 1/8, 1/8, 3/8,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/8, 1/8, 1/8, 1/8, 4/8
    ]
).reshape((11, 11))

# part a) formulate the transition matrix
print('Transition matrix:')
print(transition_matrix)

state_vector = np.ones(11)
ITERATIONS_LIMIT = 100
i = 0
while i < ITERATIONS_LIMIT:
    state_vector = state_vector.dot(transition_matrix)
    i += 1

state_vector /= sum(state_vector)

# part b) what is the probability that we end up with nothing in the warehouse overnight?
print('\nsteady state vector:')
steady_state_string_vector = [float('{0:.2f}'.format(x)) for x in state_vector]
print(steady_state_string_vector)
print('\nthe probability that we have nothing in the warehouse overnight is ', steady_state_string_vector[0])

# part c) If it costs $10 per item in the warehouse overnight, what is
# our average inventory cost per night? Hint: it's around $28 or $29

# this vector stores the cost for storing each number of items (the states) from 0 items ($0) to 10 items ($100)
inventory_cost_vector = np.linspace(start=0, stop=100, num=11)

print('inventory cost vector')
inventory_cost_string_vector = ['${:.2f}'.format(x) for x in inventory_cost_vector]
print(inventory_cost_string_vector)

average_inventory_cost = state_vector.dot(inventory_cost_vector)
print('\nThe average inventory cost per night is ${:.2f}'.format(average_inventory_cost))
