#!/usr/bin/python
import numpy as np

'''
Homework Problem Description

Consider a 3-by-3 tic-tac-toe board. At each step, a marker hops from
its current cell to an up/down/left/right adjacent cell, choosing with
equal probability among its available options.
It cannot stay in the same cell during a hop.
i) Formulate a Markov chain for it.
ii) What do you think the steady-state solution will be?
iii) Find the steady-state solution. Is it what you thought it might be? Explain.
iv) Imagine that the marker cannot hop back to the cell it just came from.
Describe any needed changes in the Markov model, but you do not have to
formulate the matrix.
'''

transition_matrix = np.array(
    [0.0, 1/2, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0,
     1/3, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0,
     0.0, 1/2, 0.0, 0.0, 0.0, 1/2, 0.0, 0.0, 0.0,
     1/3, 0.0, 0.0, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0,
     0.0, 1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 1/4, 0.0,
     0.0, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 1/3,
     0.0, 0.0, 0.0, 1/2, 0.0, 0.0, 0.0, 1/2, 0.0,
     0.0, 0.0, 0.0, 0.0, 1/3, 0.0, 1/3, 0.0, 1/3,
     0.0, 0.0, 0.0, 0.0, 0.0, 1/2, 0.0, 1/2, 0.0]
).reshape((9, 9))

print('Transition matrix:')
print(transition_matrix)

state_vector = np.ones(9)
ITERATIONS_LIMIT = 1000
i = 0
while i < ITERATIONS_LIMIT:
    state_vector = state_vector.dot(transition_matrix)
    i += 1
state_vector /= sum(state_vector)
print('steady state vector:')
print(['{0:.3f}'.format(x) for x in state_vector])
