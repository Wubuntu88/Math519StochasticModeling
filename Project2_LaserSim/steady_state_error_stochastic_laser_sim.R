# Simulation for cooling a laser temperature block connected to an adaptive material, which has as heat cooling pump
# author: William Gillespie

# made with some inspiration from http://oddhypothesis.blogspot.com/2013/02/pid-control-r.html

source('temp_update_functions.R')

#-------- START OF SIMULATION --------#

# temperatures of objects
laser_temp_start = 19
laser_goal_temp = 20
adaptive_material_temp_start = 19
ambient_temp_start = 22

# heat transfer coefficients
transfer_coeff_laser_to_adaptive_material = 0.1
transfer_coeff_air_to_laser = 0.1
transfer_coeff_air_to_adaptive_material = 0.5

# miscelaneous constants
mean_ambient_temp = 22.0

# time tick
delta_t = 0.1

#gain constants
# for P controller:
# kp = -81.0
# ki = 0
# kd = 0
# type_of_model = '(P Model)'

# # for PI controller:
kp = -39.0
ki = -6.0
kd = 0
type_of_model = '(PI Model)'

#for a PID controller: kp: 9.082, ki: 7.645, kd: 2.697"
# kp = -136.0
# ki = -49.0
# kd = -36.0
# type_of_model = '(PID Model)'

max_time_limit = 150
tt = seq(0, max_time_limit, by=delta_t)

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

AT = rep(ambient_temp_start, length(tt))

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

# the set points over time (can be constant or change)
set_points = rep(laser_goal_temp, length(tt))

control_output_change_limit = length(tt) / 2

for(i in 2:length(tt)) {
  AM[i] = AM[i-1] + (adaptive_material_deltas[i-1] + CO[i-1]) * delta_t
  PV[i] = PV[i-1] + laser_deltas[i-1] * delta_t
  AT[i] = next_ambient_temperature(amb_temp_prev = AT[i-1], amb_temp_mean = mean_ambient_temp)
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
}
# plots the process variable (laser temperature)
after_100_index = 100 / 0.1
par(col = 'darkblue', lwd = 3)
plot(tt[after_100_index:length(tt)], PV[after_100_index:length(PV)], main = paste("Process Variable over time", type_of_model, sep = " "))
lines(tt[after_100_index:length(tt)], PV[after_100_index:length(PV)])

# plots the setpoints over time
par(col = 'green', lwd = 5)
lines(tt, set_points, type='l')

par(col = 'black')
legend('topright', legend=c("Laser Temperature", "Goal Temperature"),
       col=c("blue", "green"), lty=1:1, cex=0.8)

source('cost_functions.R')
cost = sum_of_absolute_deviations(the_signal = PV[after_100_index:length(PV)], the_set_points = set_points[after_100_index:length(set_points)])
print(sprintf("cost: %.3f", cost))


rm(list = ls())