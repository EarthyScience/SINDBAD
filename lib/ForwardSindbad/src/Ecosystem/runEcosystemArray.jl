export runEcosystem!
export ecoLoc!


function getArrayView(a::AbstractArray{Float64,2}, inds)
        view(a, :, inds...)
    # return view(a, inds...)
end

function getArrayView(a::AbstractArray{Float64,3}, inds)
    # @show inds, length(inds)
    if length(inds) == 1
        view(a, :, :, inds...)
    else
        view(a, :, inds...)
    end
end

function getArrayView(a::AbstractArray{Float64,4}, inds)
    # @show size(a), inds
    if length(inds) == 1
        view(a, :, :, :, inds...)
    else
        view(a, :, :, inds...)
    end
end

function getLocData(outcubes, forcing::NamedTuple, additionaldims, loc_names)
    loc_forcing = map(forcing) do a
        inds = map(zip(loc_names,additionaldims)) do (loc_index,lv)
            lv=>loc_index
        end
        view(a;inds...)
    end
    loc_output = map(outcubes) do a
        inds = map(zip(loc_names,additionaldims)) do (loc_index,lv)
            loc_index
        end
        # @show size(a), inds, typeof(inds)
        getArrayView(a, inds)
    end
    return loc_forcing, loc_output
end


function ecoLoc!(outcubes, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, additionaldims, loc_names, land_init::NamedTuple)
    loc_forcing, loc_output = getLocData(outcubes, forcing, additionaldims, loc_names)
    all_nan = all(isnan, loc_forcing[1])
    if !all_nan
        coreEcosystem!(loc_output, approaches, loc_forcing, tem, land_init)
    end
end

function ecoLoc!(outcubes, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, additionaldims, loc_names)
    loc_forcing, loc_output = getLocData(outcubes, forcing, additionaldims, loc_names)
    all_nan = all(isnan, loc_forcing[1])
    if !all_nan
        coreEcosystem!(loc_output, approaches, loc_forcing, tem)
    end
end


function setOuputT!(outputs, land::NamedTuple, tem_variables::NamedTuple, ts::Int64)
    var_index = 1
    for group in keys(tem_variables)
        for k in tem_variables[group]
            data_ts = selectdim(outputs[var_index], 1, ts) #assumes that the first dimension is always time
            data_ts .= land[group][k]
            var_index += 1
        end
    end
end

    
"""
runModels(forcing, models, out)
"""
function runModels!(out::NamedTuple, forcing::NamedTuple, models::Tuple, tem_helpers::NamedTuple)
    return foldl(models, init=out) do o,model 
        o = Models.compute(model, forcing, o, tem_helpers)
    end
end


function runPrecompute!(out::NamedTuple, forcing::NamedTuple, models::Tuple, tem_helpers::NamedTuple)
    for model in models
        out = Models.precompute(model, forcing, out, tem_helpers)
    end
    return out
end


@noinline function theRealtimeLoopForward!(loc_output, forward_models::Tuple, forcing::NamedTuple, out::NamedTuple, tem_variables::NamedTuple, tem_helpers::NamedTuple, time_steps::Int64, otype::DataType, oforc::DataType)
    # time_steps = 1
    map(1:time_steps) do ts
        f = getForcingForTimeStep(forcing, ts)::oforc
        out = runModels!(out, f, forward_models, tem_helpers)::otype
        setOuputT!(loc_output, out, tem_variables, ts)
    end
end

function timeLoopForward!(loc_output, forward_models::Tuple, forcing::NamedTuple, out::NamedTuple, tem_variables::NamedTuple, tem_helpers::NamedTuple, time_steps::Int64)
    f = getForcingForTimeStep(forcing, 1)
    out2 = runModels!(out, f, forward_models, tem_helpers);
    theRealtimeLoopForward!(loc_output, forward_models, forcing, out2, tem_variables, tem_helpers, time_steps, typeof(out2), typeof(f))
end



function coreEcosystem!(loc_output, approaches, loc_forcing, tem, land_init)
    land_prec = runPrecompute!(land_init, getForcingForTimeStep(loc_forcing, 1), approaches, tem.helpers)
    land_spin_now = land_prec
    if tem.helpers.run.runSpinup
        land_spin_now = runSpinup(approaches, loc_forcing, land_spin_now, tem; spinup_forcing=nothing)
    end
    time_steps = getForcingTimeSize(loc_forcing)
    timeLoopForward!(loc_output,  approaches, loc_forcing, land_spin_now, tem.variables, tem.helpers, time_steps)
end

function coreEcosystem!(loc_output, approaches, loc_forcing, tem)
    #@info "runEcosystem:: running ecosystem"
    land_init = createLandInit(tem);
    land_prec = runPrecompute!(land_init, getForcingForTimeStep(loc_forcing, 1), approaches, tem.helpers)
    land_spin_now = land_prec
    if tem.helpers.run.runSpinup
        land_spin_now = runSpinup(approaches, loc_forcing, land_spin_now, tem; spinup_forcing=nothing)
    end
    time_steps = getForcingTimeSize(loc_forcing)
    timeLoopForward!(loc_output,  approaches, loc_forcing, land_spin_now, tem.variables, tem.helpers, time_steps)
end


"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, land_init::NamedTuple)
    additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    spacesize = values(tem.helpers.run.loop[additionaldims])
    spaceLocs = Iterators.product(Base.OneTo.(spacesize)...)
    qbmap(spaceLocs) do loc_names
        ecoLoc!(outcubes, approaches, forcing, tem, additionaldims, loc_names, deepcopy(land_init))
    end
end

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, ::Val{:pmap})
    additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    spacesize = values(tem.helpers.run.loop[additionaldims])
    spaceLocs = Iterators.product(Base.OneTo.(spacesize)...)
    # @everywere ecofunc = x ->  ecoLoc!(Ref(outcubes), Ref(approaches), Ref(forcing), Ref(tem), Ref(additionaldims), x)

    # @everywere ecofunc = x ->  ecoLoc!(outcubes, approaches, forcing, tem, additionaldims, x)
    # _ = pmap(ecofunc, 1:length(spaceLocs));
end

# """
# runEcosystem(approaches, forcing, land_init, tem)
# """
# function runEcosystem!(outcubes, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, ::Val{:tturbo})
#     additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
#     spacesize = values(tem.helpers.run.loop[additionaldims])
#     spaceLocs = Iterators.product(Base.OneTo.(spacesize)...) |> collect

#     @tturbo for i = eachindex(spaceLocs)
#         loc_names = spaceLocs[i]
#         ecoLoc!(outcubes, approaches, forcing, tem, additionaldims, loc_names)
#     end
# end

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, ::Val{:threads})
    additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    spacesize = values(tem.helpers.run.loop[additionaldims])
    spaceLocs = Iterators.product(Base.OneTo.(spacesize)...) |> collect

    Threads.@threads for i = eachindex(spaceLocs)
        loc_names = spaceLocs[i]
        ecoLoc!(outcubes, approaches, forcing, tem, additionaldims, loc_names)
    end
end

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, ::Val{:qbmap})
    additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    spacesize = values(tem.helpers.run.loop[additionaldims])
    spaceLocs = Iterators.product(Base.OneTo.(spacesize)...)
    qbmap(spaceLocs) do loc_names
        ecoLoc!(outcubes, approaches, forcing, tem, additionaldims, loc_names)
    end
end