export runEcosystem!, prepRunEcosystem
export ecoLoc!


@generated function getLocData!(outcubes, ::Val{forc_vars}, ::Val{out_keys}, forcing, loc_space_inds, loc_output_array, loc_forcing_array) where {forc_vars, out_keys}
    output = quote
    end
    forc_index = 1
    foreach(forc_vars) do forc
        push!(output.args, Expr(:(=), Expr(:ref, :loc_forcing_array, forc_index), Expr(:call, :getArrayView, Expr(:., :forcing, QuoteNode(forc)), :loc_space_inds)))
        forc_index += 1
    end

    foreach(out_keys) do i
        push!(output.args, Expr(:(=), Expr(:ref, :loc_output_array, i), Expr(:call, :getArrayView, Expr(:ref, :outcubes, i), :loc_space_inds)))
    end
    return output
end


# function getLocDataArray(outcubes, forcing, loc_space_map)
#     forcing_array = values(forcing)
#     loc_forcing=[]
#     inds = last.(loc_space_map)
#     foreach(forcing_array) do a
#         push!(loc_forcing, getArrayView(a, inds))
#     end

#     loc_output=[]
#     foreach(outcubes) do a
#         push!(loc_output, getArrayView(a, ar_inds))
#     end
#     return loc_forcing, loc_output
# end

function getLocData(outcubes, forcing, loc_space_map)
    loc_forcing = map(forcing) do a
        view(a;loc_space_map...)
    end
    ar_inds = last.(loc_space_map)

    loc_output = map(outcubes) do a
        getArrayView(a, ar_inds)
    end
    return loc_forcing, loc_output
end


function getLocDataArray(outcubes, forcing, loc_space_inds)
    forcing_array = AbstractArray[]
    for frc in forcing
        push!(forcing_array, frc)
    end
    loc_forcing_array=[]
    # loc_forcing_array=typeof(getArrayView(forcing[1], loc_space_inds))[]
    foreach(forcing_array) do a
        push!(loc_forcing_array, getArrayView(a, loc_space_inds))
    end

    loc_output_array=typeof(getArrayView(outcubes[1], loc_space_inds))[]
    foreach(outcubes) do a
        push!(loc_output_array, getArrayView(a, loc_space_inds))
    end
    return loc_forcing_array, loc_output_array
end


function ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, loc_space_map, land_init, f_one)
    loc_forcing, loc_output = getLocData(outcubes, forcing, loc_space_map) #312

    coreEcosystem!(loc_output, approaches, loc_forcing, tem_helpers, tem_spinup, tem_models, tem_variables, land_init, f_one)
end


function get_view(ar, val::AbstractArray, ts::Int64)
    view(ar, ts, 1:length(val))
end

function get_view(ar, val::AbstractFloat, ts::Int64)
    view(ar, ts)
end

function fill_it!(ar, val, ts::Int64)
    data_ts = get_view(ar, val, ts)
    data_ts .= val
end


@generated function setOutputT!(outputs, land, ::Val{TEM}, ts) where TEM
    output = quote
    end
    var_index = 1
        foreach(keys(TEM)) do group
        foreach(TEM[group]) do k
            push!(output.args,Expr(:(=),:data_l,Expr(:.,Expr(:.,:land,QuoteNode(group)),QuoteNode(k))))
                    push!(output.args,quote
                data_o = outputs[$var_index]
                fill_it!(data_o, data_l, ts)
            end)
            var_index += 1
        end
    end
    output
end


function runPrecompute!(out, forcing, models, tem_helpers)
    return foldl_unrolled(models, init=out) do o,model 
        o = Models.precompute(model, forcing, o, tem_helpers)
    end
end

function timeLoopForward!(loc_output, forward_models, forcing, out, tem_variables, tem_helpers, time_steps::Int64, f_one)
    # ftype = get_dtype(dtypes, dtypes_list, :forcing_one_type)
    f_t = f_one
    if tem_helpers.run.debugit
        time_steps = 1
    end
    for ts = 1:time_steps
        if tem_helpers.run.debugit
            @show "forc"
            @time f = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_t)
            println("-------------")
            @show "each model"
            @time out = runModels!(out, f, forward_models, tem_helpers, Val(:debugit))
            println("-------------")
            @show "all models"
            @time out = runModels!(out, f, forward_models, tem_helpers)
            println("-------------")
            @show "out"
            @time setOutputT!(loc_output, out, tem_variables, ts)
            println("-------------")
        else
            f = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_one)
            out = runModels!(out, f, forward_models, tem_helpers)#::otype
            setOutputT!(loc_output, out, tem_variables, ts)
        end
    end
end



function coreEcosystem!(loc_output, approaches, loc_forcing, tem_helpers, tem_spinup, tem_models, tem_variables, land_init, f_one)
    land_spin_now = land_init

    if tem_helpers.run.runSpinup
        land_spin_now = runSpinup(approaches, loc_forcing, land_spin_now, tem_helpers, tem_spinup, tem_models, typeof(land_init), f_one; spinup_forcing=nothing)
    end
    time_steps = getForcingTimeSize(loc_forcing, Val(keys(loc_forcing)))
    timeLoopForward!(loc_output, approaches, loc_forcing, land_spin_now, tem_variables, tem_helpers, time_steps, f_one)
end

function doOneLocation(outcubes::AbstractArray, land_init, approaches, forcing, tem, loc_space_map)
    loc_forcing, loc_output = getLocData(outcubes, forcing, loc_space_map)

    land_prec = runPrecompute!(land_init, getForcingForTimeStep(loc_forcing, 1), approaches, tem.helpers)
    f_one = getForcingForTimeStep(loc_forcing, 1)
    land_one = runModels!(land_prec, f_one, approaches, tem.helpers);
    return land_one, f_one  
end



"""
prepRunEcosystem(approaches, forcing, land_init, tem)
"""
function prepRunEcosystem(outcubes::AbstractArray, land_init, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple)
    loopvars = keys(tem.helpers.run.loop) |> collect
    additionaldims = setdiff(loopvars,[:time])::Vector{Symbol}
    spacesize = values(tem.helpers.run.loop[additionaldims])::Tuple
    space_locs = vec(Iterators.product(Base.OneTo.(spacesize)...) |> collect)::Vector{NTuple{length(tem.helpers.run.loop)-1,Int}}

    loc_space_maps = map(space_locs) do loc_names
        map(zip(loc_names,additionaldims)) do (loc_index,lv)
            lv=>loc_index
        end
    end
    allNans = Bool[]
    for i in eachindex(loc_space_maps)
        loc_forcing, _ = getLocData(outcubes, forcing, loc_space_maps[i]) #312
        push!(allNans, all(isnan, loc_forcing[1]))
    end
    loc_space_maps = loc_space_maps[allNans .== false]
    land_one, f_one  = doOneLocation(outcubes, land_init, approaches, forcing, tem, loc_space_maps[1])
    land_init_space = Tuple([deepcopy(land_one) for _ in 1:length(loc_space_maps)])
    return loc_space_maps, land_init_space, f_one
end


"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes::AbstractArray, land_init::NamedTuple, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple)
    loc_space_maps, land_init_space, f_one = prepRunEcosystem(outcubes, land_init, approaches, forcing, tem)
    parallelizeIt(outcubes, approaches, forcing, tem.helpers, tem.spinup, tem.models, Val(tem.variables), loc_space_maps, land_init_space, f_one, tem.helpers.run.parallelization)
end

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes::AbstractArray, land_init::NamedTuple, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, loc_space_maps, land_init_space, f_one)
    parallelizeIt(outcubes, approaches, forcing, tem.helpers, tem.spinup, tem.models, Val(tem.variables), loc_space_maps, land_init_space, f_one, tem.helpers.run.parallelization)
end

function parallelizeIt(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, loc_space_maps, land_init_space, f_one, ::Val{:threads})
    Threads.@threads for i = eachindex(loc_space_maps)
        ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, loc_space_maps[i], land_init_space[i], f_one)
        end
end    

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function parallelizeIt(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, loc_space_maps, land_init_space, f_one, ::Val{:qbmap})  
    qbmap(loc_space_maps) do loc_space_map
        ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, loc_space_map, land_init_space[Threads.threadid()], f_one)
    end
end