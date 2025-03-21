export optimizeTEM


"""
    optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `observations`: a NT or a vector of arrays of observations, their uncertainties, and mask to use for calculation of performance metric/loss
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
"""
optimizeTEM

function optimizeTEM(forcing::NamedTuple, observations, info::NamedTuple)
    # get the subset of parameters table that consists of only optimized parameters
    opti_helpers = prepOpti(forcing, observations, info, info.optimization.optimization_cost_method)

    # run the optimizer
    optim_para = optimizer(opti_helpers.cost_function, opti_helpers.default_values, opti_helpers.lower_bounds, opti_helpers.upper_bounds, info.optimization.algorithm.options, info.optimization.algorithm.method)

    optim_para = backScaleParameters(optim_para, opti_helpers.tbl_params, info.optimization.optimization_parameter_scaling)

    # update the parameter table with the optimized values
    opti_helpers.tbl_params.optim .= optim_para
    return opti_helpers.tbl_params
end
