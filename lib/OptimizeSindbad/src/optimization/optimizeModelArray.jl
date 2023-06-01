export optimizeModelArray
export getSimulationDataArray,  getLossArray
export getDataArray
export getLossVectorArray

"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
"""
function getDataArray(outsmodel::NamedTuple, observations::NamedTuple, obsV::Symbol, modelVarInfo::Tuple)
    ŷ =  getproperty(outsmodel, modelVarInfo[2])
    y = getproperty(observations, obsV)
    yσ = getproperty(observations, Symbol(string(obsV) * "_σ"))
    # todo: get rid of the permutedims hack ... should come from input/observation data, which should have dimensions in time, lat, lon or depth, time, lat, lon
    if size(ŷ) != size(y)
        @warn "$(obsV) size:: model: $(size(ŷ)), obs: $(size(y)) => permuting dimensions of model ŷ"
        # ŷ = permutedims(ŷ, (2, 3, 1))
        ŷ = y .* rand()
    end
    return (y, yσ, ŷ)
end

"""
getSimulationData(outsmodel, observations, modelVariables, obsVariables)
"""
function getDataArray(outsmodel::landWrapper, observations::NamedTuple, obsV::Symbol, modelVarInfo::Tuple)
    ŷField = getproperty(outsmodel, modelVarInfo[1])
    ŷ = getproperty(ŷField, modelVarInfo[2])
    y = getproperty(observations, obsV)
    yσ = getproperty(observations, Symbol(string(obsV) * "_σ"))
    # todo: get rid of the permutedims hack ...
    if size(ŷ) != size(y)
        # @warn "$(obsV) size:: model: $(size(ŷ)), obs: $(size(y)) => permuting dimensions of model ŷ"
        ŷ = y .* rand()
        # ŷ = permutedims(ŷ, (2, 3, 1))
    end
    return (y, yσ, ŷ)
end

"""
    combineLoss(lossVector, ::Val{:sum})
return the total of cost of each constraint as the overall cost
"""
function combineLossArray(lossVector::AbstractArray, ::Val{:sum})
    return sum(lossVector)
end

"""
    combineLoss(lossVector, ::Val{:minimum})
return the minimum of cost of each constraint as the overall cost
"""
function combineLossArray(lossVector::AbstractArray, ::Val{:minimum})
    return minimum(lossVector)
end


"""
    combineLoss(lossVector, ::Val{:maximum})
return the maximum of cost of each constraint as the overall cost
"""
function combineLossArray(lossVector::AbstractArray, ::Val{:maximum})
    return maximum(lossVector)
end

"""
    combineLoss(lossVector, percentile_value)
return the percentile_value^th percentile of cost of each constraint as the overall cost
"""
function combineLossArray(lossVector::AbstractArray, percentile_value::T) where {T<:Real}
    return percentile(lossVector, percentile_value)
end

"""
getLossVector(observations::NamedTuple, tblParams::Table, optimVars::NamedTuple, optim::NamedTuple)
returns a vector of losses for variables in info.optim.variables2constrain
"""
function getLossVectorArray(observations::NamedTuple, model_output, optim::NamedTuple)
    lossVec = []
    cost_options = optim.costOptions
    optimVars = optim.variables.optim
    for var_row in cost_options
        obsV = var_row.variable
        lossMetric = var_row.costMetric
        mod_variable = getfield(optimVars, obsV)
        (y, yσ, ŷ) = getDataArray(model_output, observations, obsV, mod_variable)
        metr = loss(y, yσ, ŷ, Val(lossMetric))
        if isnan(metr)
            push!(lossVec, 1.0E19)
        else
            push!(lossVec, metr)
        end
        @info "$(obsV) => $(lossMetric): $(metr)"
    end
    return lossVec
end

"""
getLoss(pVector, approaches, initOut, forcing, observations, tblParams, obsVariables, modelVariables)
"""
function getLossArray(pVector::AbstractArray, forcing::NamedTuple, output::Vector, output_variables, observations::NamedTuple, tblParams::Table, tem::NamedTuple, optim::NamedTuple,  loc_space_maps, land_init_space, f_one, loc_forcing, loc_output)
    # tblParams.optim .= pVector # update the parameters with pVector
    # @show pVector, typeof(pVector)
    if eltype(pVector) <: ForwardDiff.Dual
        tblParams.optim .= [tem.helpers.numbers.sNT(ForwardDiff.value(v)) for v ∈ pVector] # update the parameters with pVector
    else
        tblParams.optim .= pVector # update the parameters with pVector
    end
    
    
    newApproaches = updateParameters(tblParams, tem.models.forward)
    runEcosystem!(output, tem.models.forward, forcing, tem, loc_space_maps, land_init_space, f_one, loc_forcing, loc_output)
    model_data = (; Pair.(output_variables, output)...)
    # run_output = output.data;
    # outevolution = runEcosystemArray(newApproaches, forcing, initOut, tem; spinup_forcing=spinup_forcing) # spinup + forward run!

    loss_vector = getLossVectorArray(observations, model_data, optim)
    @info "-------------------"

    return combineLossArray(loss_vector, Val(optim.multiConstraintMethod))
end

"""
optimizeModel(forcing, observations, selectedModels, optimParams, initOut, obsVariables, modelVariables)
"""
function optimizeModelArray(forcing::NamedTuple, output::Vector, output_variables, observations::NamedTuple,tem::NamedTuple, optim::NamedTuple; spinup_forcing=nothing)
    # get the list of observed variables, model variables to compare observation against, 
    # obsVars, optimVars, storeVars = getConstraintNames(info);

    # get the subset of parameters table that consists of only optimized parameters
    tblParams = Sindbad.getParameters(tem.models.forward, optim.optimized_parameters)

    # get the defaults and bounds
    default_values = tem.helpers.numbers.sNT.(tblParams.defaults)
    lower_bounds = tem.helpers.numbers.sNT.(tblParams.lower)
    upper_bounds = tem.helpers.numbers.sNT.(tblParams.upper)


    loc_space_maps, land_init_space, f_one, loc_forcing, loc_output  = prepRunEcosystem(output, tem.models.forward, forcing, tem);

    @infiltrate

    # make the cost function handle
    cost_function = x -> getLossArray(x, forcing, output, output_variables,
        observations, tblParams, tem, optim,  loc_space_maps, land_init_space, f_one, loc_forcing, loc_output)

    # run the optimizer
    optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, optim.algorithm.options, Val(optim.algorithm.method))

    # update the parameter table with the optimized values
    tblParams.optim .= optim_para
    return tblParams
end

