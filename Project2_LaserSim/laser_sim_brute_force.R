# Simulation for cooling a laser temperature block connected to an adaptive material, which has as heat cooling pump
# author: William Gillespie

# made with some inspiration from http://oddhypothesis.blogspot.com/2013/02/pid-control-r.html

source('temp_update_functions.R')

#-------- START OF SIMULATION --------#
source('cost_functions.R')

simulate_laser_cooling = function(kp, ki, kd){
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
  
  tt = seq(0, 70, by=delta_t)
  
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
    #E[i] = laser_goal_temp - PV[i]
    EI[i] = EI[i-1] + E[i] * delta_t
    ED[i] = (E[i] - E[i-1]) / delta_t
    # use the PID Errors to calculate the control output
    CO[i] = kp * E[i] + ki * EI[i] + kd * ED[i]
  }

  
  cost = sum_of_absolute_deviations(the_signal = PV, the_set_points = set_points)
  return(cost)
}
#gain constants
# for P controller:
# kp = -7.5
# ki = 0
# kd = 0

# for PI controller:
# kp = -6.811
# ki = -0.344
# kd = 0

#for a PID controller: kp: 9.082, ki: 7.645, kd: 2.697"
# kp = -7.082
# ki = -7.645
# kd = -2.697

kp_range = seq(-100, -50, by=1)
ki_range = seq(0, 0, by=1)
kd_range = seq(0, 0, by=1)

# brute force range for PI
# kp_range = seq(-50, -1, by=1)
# ki_range = seq(-10, -1, by=1)
# kd_range = seq(0, 0, by=1)

# # brute force range for PID
# kp_range = seq(-150, -100, by=5)
# ki_range = seq(-150, -100, by=1)
# kd_range = seq(-20, -17, by=1)

best_kp = -1
best_ki = 0
best_kd = 0

search_space = length(kp_range) * length(ki_range) * length(kd_range)
print(search_space)
best_cost = 300000 # big number that will easily be beaten on the first iteration
iterations_so_far = 0
for(the_kp in kp_range){
  for(the_ki in ki_range){
    for(the_kd in kd_range){
      the_cost = simulate_laser_cooling(kp = the_kp, ki = the_ki, kd = the_kd)
      if(the_cost < best_cost){
        best_cost = the_cost
        best_kp = the_kp
        best_ki = the_ki
        best_kd = the_kd
      }
      iterations_so_far = iterations_so_far + 1
    }
    print(sprintf("%4.2f%% done", (iterations_so_far / search_space) * 100))
  }
}

print(sprintf("cost: %.3f", best_cost))
print(sprintf("best kp: %.3f", best_kp))
print(sprintf("best ki: %.3f", best_ki))
print(sprintf("best kd: %.3f", best_kd))



