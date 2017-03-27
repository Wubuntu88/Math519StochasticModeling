temp = read.csv('ex1WaterMoleculeTransitionMatrix.csv', header = FALSE)
trans_matrix = as.matrix(temp)

state_vector = t(as.matrix(c(0.2, 0.2, 0.2, 0.2, 0.2, 0.2)))
header_values = c('Michigan', 'Superior', 'Huron', 'Eire', 'Ontario', 'Air')
colnames(state_vector) = header_values
print('initial state vector:')
print(state_vector)

iterations_left = 1000
while(iterations_left > 0){
  previous_state_vector = state_vector
  state_vector = state_vector %*% trans_matrix
  iterations_left = iterations_left - 1
}
print('steady state vector')
print(header_values)
print(sprintf('%.3f', state_vector))
