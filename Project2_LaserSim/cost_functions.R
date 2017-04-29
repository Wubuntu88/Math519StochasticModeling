
sum_of_absolute_deviations = function(the_signal, the_set_points){
  stopifnot(length(the_signal) == length(the_set_points))
  the_differences = the_signal - the_set_points
  the_abs_values = abs(the_differences)
  the_sum_of_abs_values = sum(the_abs_values)
  return(the_sum_of_abs_values)
}
