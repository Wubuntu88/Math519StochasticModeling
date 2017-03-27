#!/usr/bin/python

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

transition_matrix = np.array(
    [0.8, 0.1, 0.1,
     0.6, 0.2, 0.2,
     0.4, 0.3, 0.3]
).reshape((3, 3))

print('Transition matrix:')
print(transition_matrix)

start_value = 1.0 / 3.0
test_1_convergence_array = [start_value]
test_2_convergence_array = [start_value]
test_3_convergence_array = [start_value]

state_vector = np.array([start_value, start_value, start_value])
ITERATIONS_LIMIT = 5
i = 0
while i < ITERATIONS_LIMIT:
    state_vector = state_vector.dot(transition_matrix)
    test_1_convergence_array.append(state_vector[0])
    test_2_convergence_array.append(state_vector[1])
    test_3_convergence_array.append(state_vector[2])
    i += 1
state_vector /= sum(state_vector)
print('steady state vector:')
print(state_vector)

plt.plot(test_1_convergence_array, c='burlywood', linewidth=8)
plt.plot(test_2_convergence_array, c='mediumaquamarine', linewidth=12)
plt.plot(test_3_convergence_array, c='crimson', linewidth=4)
plt.title('Convergence over time of proportion of test types taken', fontsize=22)
plt.xlabel('# iteration', fontsize=20)
plt.ylabel('proportion of test type taken', fontsize=20)
plt.tick_params(labelsize=16)
plt.show()
