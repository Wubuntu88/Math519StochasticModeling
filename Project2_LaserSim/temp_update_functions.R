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