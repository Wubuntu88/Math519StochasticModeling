# Simulation for cooling a laser temperature block connected to an adaptive material, which has as heat cooling pump
# author: William Gillespie

# BEWARE: this script needs some fixing.

# made with some inspiration from http://oddhypothesis.blogspot.com/2013/02/pid-control-r.html

# helper functions
next_ambient_temperature = function(amb_temp_prev, amb_temp_mean) {
  next_temp = amb_temp_mean + (amb_temp_prev - amb_temp_mean) * 0.9 + rnorm(1) * 0.2
  return(next_temp)
}

next_laser_delta = function(the_laser_temp,
                            the_adp_mat_temp,
                            the_laser_to_adp_mat_transfer_coeff,
                            the_air_to_laser_transfer_coeff,
                            the_amb_temp){
  #'@return: returns the change in the temperature of the laser for the next time tick
  laser_heating_delta = 3.4 # + 0.05 * rnorm(1) # maybe add randomness later
  # the delta temp for the temperature transfered out of the laser to the adaptive material
  the_laser_delta = the_laser_to_adp_mat_transfer_coeff * (the_adp_mat_temp - the_laser_temp)
  # the delta temp for the laser / ambient temperature temperature transfer
  the_amb_temp_to_laser_delta = the_air_to_laser_transfer_coeff * (the_amb_temp - the_laser_temp)
  # the sum of the above two terms is the change in the laser's temperature
  return(laser_heating_delta + the_laser_delta + the_amb_temp_to_laser_delta)
}

next_adaptive_material_delta = function(the_laser_temp,
                                       the_adp_mat_temp,
                                       the_laser_to_adp_mat_transfer_coeff,
                                       the_air_to_adp_mat_transfer_coeff,
                                       the_amb_temp) {
  #'@return: returns the change in the adaptive material for the next time tick
  # the delta temp for the temperature transfered out of the laser to the adaptive material
  adp_mat_delta = the_laser_to_adp_mat_transfer_coeff * (the_laser_temp - the_adp_mat_temp)
  # the delta temp for the adaptive material / ambient temperature transfer
  the_amb_temp_to_adp_mat_delta = the_air_to_adp_mat_transfer_coeff * (the_amb_temp - the_adp_mat_temp)
  # the sum of the above two terms is the change in the adaptive material's temperature
  return(adp_mat_delta + the_amb_temp_to_adp_mat_delta)
}

#-------- START OF SIMULATION --------#

# temperatures of objects
laser_temp_start = 19
laser_goal_temp = 20
subsequent_laser_goal_temp = 19.5
adaptive_material_temp_start = 19
ambient_temp_start = 22

# heat transfer coefficients
transfer_coeff_laser_to_adaptive_material = 0.1
#transfer_coeff_air_to_laser = 0.01
#transfer_coeff_air_to_adaptive_material = 0.005
transfer_coeff_air_to_laser = 0.1
transfer_coeff_air_to_adaptive_material = 0.5
# miscelaneous constants
mean_ambient_temp = 22.0

# time tick
delta_t = 0.1

#gain constants
# kp = -0.5
# ki = -0.5
# kd = -3.0
kp = -.5
ki = 0
kd = 0


max_time = 100
tt = seq(0, max_time, by=delta_t)

# initialize the following to a vector of zeros
# as long as the time variable tt
# - PV, process variable (laser temp)
# - AM, adaptive material temperature
# - CO, control output
PV = AM = CO = rep(0, length(tt))

PV[1] = laser_temp_start # initial state of the process variable (laser temperature)
AM[1] = adaptive_material_temp_start # initial state of the adaptive material

# - Error (is also the proportional error)
# - EI, error integral
# - ED, error derivative
E = EI = ED = rep(0, length(tt))
E[1] = 1
EI[1] = 0
ED[1] = 0
CO[1] = kp * E[1] + ki * EI[1] + kd * ED[1]

# - AT, ambient temperature array

AT = rep(0, length(tt))
AT[1] = ambient_temp_start

# - arrays of the temp changes of the lasers and adaptive material
laser_deltas = adaptive_material_deltas = rep(0, length(tt))
# initialize the first adaptive material delta so that I can use it in the loop below
adaptive_material_deltas[1] = next_adaptive_material_delta(the_laser_temp = PV[1],
                                                          the_adp_mat_temp = AM[1],
                                                          the_laser_to_adp_mat_transfer_coeff = transfer_coeff_laser_to_adaptive_material,
                                                          the_air_to_adp_mat_transfer_coeff = transfer_coeff_air_to_adaptive_material,
                                                          the_amb_temp = AT[1])
laser_deltas[1] = next_laser_delta(the_laser_temp = PV[1],
                                   the_adp_mat_temp = AM[1],
                                   the_laser_to_adp_mat_transfer_coeff = transfer_coeff_laser_to_adaptive_material,
                                   the_air_to_laser_transfer_coeff = transfer_coeff_air_to_laser,
                                   the_amb_temp = AT[1])

set_point_change_index = floor(length(tt) * 3 / 4)

# the set points over time (can be constant or change)
set_points = rep(laser_goal_temp, length(tt))
set_points[which(tt > floor(set_point_change_index * delta_t))] = subsequent_laser_goal_temp


print(set_points)
print(length(set_points))
print(set_point_change_index)
for(i in 2:length(tt)) {
  AM[i] = AM[i-1] + (adaptive_material_deltas[i-1] + CO[i-1]) * delta_t
  PV[i] = PV[i-1] + laser_deltas[i-1] * delta_t
  adaptive_material_deltas[i] = next_adaptive_material_delta(the_laser_temp = PV[i],
                                                 the_adp_mat_temp = AM[i],
                                                 the_laser_to_adp_mat_transfer_coeff = transfer_coeff_laser_to_adaptive_material,
                                                 the_air_to_adp_mat_transfer_coeff = transfer_coeff_air_to_adaptive_material,
                                                 the_amb_temp = AT[i])
  laser_deltas[i] = next_laser_delta(the_laser_temp = PV[i],
                                      the_adp_mat_temp = AM[i],
                                      the_laser_to_adp_mat_transfer_coeff = transfer_coeff_laser_to_adaptive_material,
                                      the_air_to_laser_transfer_coeff = transfer_coeff_air_to_laser,
                                      the_amb_temp = AT[i])
  PV[i] = PV[i] + laser_deltas[i] * delta_t
  
  # calculate the proportional, integral, and derivative errors
  E[i] = PV[i] - set_points[i]
  EI[i] = EI[i-1] + E[i] * delta_t
  ED[i] = (E[i] - E[i-1]) / delta_t
  
  # use the PID Errors to calculate the control output
  CO[i] = kp * E[i] + ki * EI[i] + kd * ED[i]
  
  AT[i] = next_ambient_temperature(amb_temp_prev = AT[i-1], amb_temp_mean = mean_ambient_temp)
}

#--- START OF ZIEGLER NICHOLS ---#
after_CO_changed_index = floor(set_point_change_index)
after_CO_changed_slice = PV[after_CO_changed_index:length(PV)]

#calculating delta PV
min_pv_after_change = min(after_CO_changed_slice)
steady_pv_right_before_co_change = PV[after_CO_changed_index - 1]

#calculating CO before change to then calculate delta CO
CO_before_change = CO[set_point_change_index - 1]

delta_PV = min_pv_after_change - steady_pv_right_before_co_change

# find inflection point
after_CO_changed_pv_deltas = rep(0, length(after_CO_changed_slice) - 1)
after_CO_changed_time_axis = seq(0, length(after_CO_changed_pv_deltas) - 1)
for(i in 1:length(after_CO_changed_slice) - 1)
  after_CO_changed_pv_deltas[i] = after_CO_changed_slice[i+1] - after_CO_changed_slice[i]

plot(after_CO_changed_time_axis, after_CO_changed_pv_deltas)
index_of_min_element = which.min(after_CO_changed_pv_deltas)
minimum_value = min(after_CO_changed_slice)
maximum_value = max(after_CO_changed_slice)
derivative = min(after_CO_changed_pv_deltas) / delta_t # dividing by delta t is important!!
value_at_63_percent_of_min = 0.63 * (minimum_value - maximum_value) + maximum_value

x_offset = floor((set_point_change_index + index_of_min_element) * .1)
y_value_at_min_derivative = after_CO_changed_slice[index_of_min_element]
y_intercept = y_value_at_min_derivative - derivative * x_offset

offset_index = after_CO_changed_index + index_of_min_element

# now I will find tau_start and tau_end
tau_xcoord_start = (subsequent_laser_goal_temp - y_intercept) / derivative
tau_xcoord_end = 0
for(j in 2:length(after_CO_changed_slice)){
  if(value_at_63_percent_of_min <= after_CO_changed_slice[j-1] && value_at_63_percent_of_min >= after_CO_changed_slice[j]){
    tau_xcoord_end = (j - 1) * 0.1 + floor(set_point_change_index * 0.1)
    break
  }
}

t_d_length = tau_xcoord_start - floor(set_point_change_index * 0.1)
tau_length = tau_xcoord_end - tau_xcoord_start

#--- may also need to compute lambda (example in the bat book on pid tuning)


#plots the process variable (laser temperature)
par(col = 'darkblue', lwd = 3)
plot(tt, PV)
lines(tt, PV)

# plots the setpoints over time
par(col = 'green', lwd = 5)
lines(tt, set_points, type='l')
abline(v=floor(set_point_change_index * delta_t), col = 'purple')

par(col = 'orange', lwd = 4)
abline(a = y_intercept, b = derivative)

par(col = 'darkblue', lwd = 3)
plot(tt[set_point_change_index:length(tt)], PV[set_point_change_index:length(PV)])
par(col = 'green', lwd = 5)
abline(a = laser_goal_temp, b = 0.0)
par(col = 'purple', lwd = 5)
abline(a = minimum_value, b = 0.0)
par(col = 'lightblue', lwd = 5)
abline(a = value_at_63_percent_of_min, b = 0.0)
par(col = 'orange', lwd = 4)
abline(a = y_intercept, b = derivative)
par(col = 'red', lwd = 4)
abline(v = tau_xcoord_start)
abline(v = tau_xcoord_end)

rm(list = ls())













