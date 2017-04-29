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
kp = -0.5
ki = -0.5
kd = -3.0


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

control_output_change_limit = floor(length(tt) * 3 / 4)
control_output_change_value = -25
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
  if(i < control_output_change_limit){
      CO[i] = kp * E[i] + ki * EI[i] + kd * ED[i]
  }else{
    CO[i] = control_output_change_value
  }
}

#--- START OF ZIEGLER NICHOLS ---#
after_CO_changed_index = floor(control_output_change_limit)
after_CO_changed_slice = PV[after_CO_changed_index:length(PV)]

#calculating delta PV
min_pv_after_change = min(after_CO_changed_slice)
steady_pv_right_before_co_change = PV[after_CO_changed_index - 1]

#calculating CO before change to then calculate delta CO
CO_before_change = CO[control_output_change_limit - 1]
# print(sprintf("CO change value: %.2f", control_output_change_value))
# print(sprintf("CO before change: %.2f", CO_before_change))
# calculate gp: the % change of the PV / the % change of the CO
delta_PV = min_pv_after_change - steady_pv_right_before_co_change
delta_CO = control_output_change_value - CO_before_change

# print(sprintf("delta PV: %.2f", delta_PV))
# print(sprintf("delta CO: %.2f", delta_CO))

gp = delta_PV / delta_CO

# print(sprintf("gp: %.2f", gp))

# find inflection point
after_CO_changed_pv_deltas = rep(0, length(after_CO_changed_slice) - 1)
after_CO_changed_time_axis = seq(0, length(after_CO_changed_pv_deltas) - 1)
for(i in 1:length(after_CO_changed_slice) - 1)
  after_CO_changed_pv_deltas[i] = after_CO_changed_slice[i+1] - after_CO_changed_slice[i]

# -- Plots the derivative over time -- #
par(col = 'darkorange', lwd = 3)
#plot(after_CO_changed_time_axis, after_CO_changed_pv_deltas, main = 'Derivative of Laser Temperature over time after the Controller Output step change', cex.lab = 1.5, cex.main = 2.0)

# time axis for deltas starts at the corresponding time value for when the controller output is switched.
# the end index is subtracted by 1 because we get the deltas, which shortens values in the array by one
end_index_for_time = length(tt) - 1
plot(tt[control_output_change_limit:end_index_for_time], after_CO_changed_pv_deltas, xlab = 'Time Ticks', main = 'Derivative of Laser Temperature over time after the Controller Output step change', cex.lab = 1.5, cex.main = 2.0)


index_of_min_element = which.min(after_CO_changed_pv_deltas)
minimum_value = min(after_CO_changed_slice)
maximum_value = max(after_CO_changed_slice)
derivative = min(after_CO_changed_pv_deltas) / delta_t # dividing by delta t is important!!
value_at_63_percent_of_min = 0.63 * (minimum_value - maximum_value) + maximum_value

x_offset = floor((control_output_change_limit + index_of_min_element) * .1)
y_value_at_min_derivative = after_CO_changed_slice[index_of_min_element]
y_intercept = y_value_at_min_derivative - derivative * x_offset

offset_index = after_CO_changed_index + index_of_min_element

# now I will find tau_start and tau_end
tau_xcoord_start = (laser_goal_temp - y_intercept) / derivative
tau_xcoord_end = 0
for(j in 2:length(after_CO_changed_slice)){
  if(value_at_63_percent_of_min <= after_CO_changed_slice[j-1] && value_at_63_percent_of_min >= after_CO_changed_slice[j]){
    tau_xcoord_end = (j - 1) * 0.1 + floor(control_output_change_limit * 0.1)
    break
  }
}

t_d_length = tau_xcoord_start - floor(control_output_change_limit * 0.1)
tau_length = tau_xcoord_end - tau_xcoord_start

print(sprintf("tau: %.3f", tau_length))
print(sprintf("derivative: %.3f", derivative))

#--- may also need to compute lambda (example in the bat book on pid tuning)

#--- calculating the controller gain according to: http://blog.opticontrols.com/archives/477
# for proportional controller
Kc_P = tau_length / (gp * t_d_length)
print(sprintf("P model - Kc: %.3f", Kc_P))

# for the PI controller
Kc_PI = (0.9 * tau_length) / (gp * t_d_length)
Ti_PI = 3.33 * t_d_length

print(sprintf("PI model - Kc: %.3f, Ti: %.3f", Kc_PI, Ti_PI))

# for the PID Controller
Kc_PID = (1.2 * tau_length) / (gp * t_d_length)
Ti_PID = 2 * t_d_length
Td_PID = 0.5 * t_d_length
print(sprintf("PID model - Kc: %.3f, Ti: %.3f, Td: %.3f", Kc_PID, Ti_PID, Td_PID))

#plots the process variable (laser temperature)
par(col = 'darkblue', lwd = 3)
plot(tt, PV, xlab = 'Time Ticks', ylab = 'Laser Temperature', main = 'Laser Temperature over time, \nbefore and after Controller Output change', cex.lab = 1.5, cex.main = 2.0)
lines(tt, PV)

# plots the setpoints over time
par(col = 'green', lwd = 5)
lines(tt, set_points, type='l')
abline(v=floor(control_output_change_limit * delta_t), col = 'purple')

# plots the tangent line
par(col = 'orange', lwd = 4)
abline(a = y_intercept, b = derivative)
par(col = 'black')
legend('topright', legend=c("Laser Temperature", "Goal Temperature", "Tangent Line", "Time of controller output change"),
       col=c("blue", "green", "orange", "purple"), lty=1:1, cex=0.8)

# plotting the sub section where the controller output has changed
par(col = 'darkblue', lwd = 3)
plot(tt[control_output_change_limit:length(tt)], PV[control_output_change_limit:length(PV)], xlab = 'Time Ticks', ylab = 'Laser Temperature', main = 'Laser Temperature over time\nafter Controller Output change', cex.lab = 1.5, cex.main = 2.0)
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

par(col = 'black')
legend('topright', legend=c("Laser Temperature", "Goal Temperature", "Tangent Line", "Time of controller output change"),
       col=c("blue", "green", "orange", "purple"), lty=1:1, cex=0.8)

plot(tt, CO, col = 'purple', xlab = 'Time Ticks', ylab = 'Controller Output', main = 'Controller Output over Time', cex.lab = 1.5, cex.main = 2.0)
rm(list = ls())