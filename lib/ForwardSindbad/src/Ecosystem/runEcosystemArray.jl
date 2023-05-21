export runEcosystem!, prepRunEcosystem
export ecoLoc!


function getArrayView(a::AbstractArray{Float64,2}, inds::AbstractArray)
    # @show inds, length(inds), typeof(inds)
        view(a, :, inds...)
    # return view(a, inds...)
end

function getArrayView(a::AbstractArray{Float64,3}, inds::AbstractArray)
    # @show inds, length(inds), typeof(inds)
    if length(inds) == 1
        view(a, :, :, inds...)
    else
        view(a, :, inds...)
    end
end

function getArrayView(a::AbstractArray{Float64,4}, inds::AbstractArray)
    # @show size(a), inds, typeof(inds)
    if length(inds) == 1
        view(a, :, :, :, inds...)
    else
        view(a, :, :, inds...)
    end
end

function getLocData(outcubes::AbstractArray, forcing, additionaldims, loc_names)
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


function ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, additionaldims, loc_names, land_init, dtypes, dtypes_list)
    # loc_forcing, loc_output = getLocData(outcubes, forcing, additionaldims, loc_names)
    loc_forcing::get_dtype(dtypes, dtypes_list, :loc_forcing_type), loc_output::get_dtype(dtypes, dtypes_list, :loc_output_type) = getLocData(outcubes, forcing, additionaldims, loc_names)
    all_nan = all(isnan, loc_forcing[1])
    if !all_nan
        coreEcosystem!(loc_output, approaches, loc_forcing, tem_helpers, tem_spinup, tem_models, tem_variables, land_init, dtypes, dtypes_list)
    end
end


function get_view(ar, val::AbstractArray, ts::Int64)
    return view(ar, ts, 1:length(val))
end

function get_view(ar, val::AbstractFloat, ts::Int64)
    return view(ar, ts)
end

function fill_it!(ar, val, ts::Int64)
    data_ts = get_view(ar, val, ts)
    data_ts .= val
    # return nothing
end

# function fill_it!(ar::AbstractArray{Float64,2}, val::AbstractArray, ts::Int64)
#     # @show "nothere", ar[ts], val, typeof(ar), typeof(ar[ts])
#     for i in CartesianIndices(val)
#         ar[ts, i, :] .= val[i]
#     end
# end


# function fill_it!(ar::AbstractArray{Float64,1}, val::AbstractFloat, ts::Int64)
#     # @show "here", ar[ts], val, typeof(ar), typeof(ar[ts])
#     ar[ts] = val
# end




@generated function setOuputT!(outputs, land, ::Val{TEM}, ts, dtypes, dtypes_list) where TEM
    output = quote
        # var_index = 1
    end
    var_index = 1
        foreach(keys(TEM)) do group
        # push!(output.args,Expr(:(=),:landgroup,Expr(:.,:land,QuoteNode(group))))
        foreach(TEM[group]) do k
            push!(output.args,Expr(:(=),:data_l,Expr(:.,Expr(:.,:land,QuoteNode(group)),QuoteNode(k))))
                # push!(output.args,Expr(:(=),:data_l, Expr(:(::), Expr(:.,Expr(:.,:land,QuoteNode(group)),QuoteNode(k)), Expr(:ref, :dtypes_list, var_index))))
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

function timeLoopForward!(loc_output, forward_models, forcing, out, tem_variables, tem_helpers, time_steps::Int64, dtypes, dtypes_list)
    ftype = get_dtype(dtypes, dtypes_list, :forcing_one_type)
    # f_t = Array{Union{KeyedArray, AbstractFloat}}(undef, length(forcing))
    f_t = getForcingForTimeStep(forcing, 1)::ftype

    debugit = true
    debugit = false
    if debugit
        time_steps = 1
    end
    for ts = 1:time_steps
    # map(1:time_steps) do ts
        if debugit
            @show "forc"
            # @time f = getForcingForTimeStep(forcing, ts, f_t)
            # @time f = getForcingForTimeStep(forcing, ts)
            @time f = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_t)
            @show "mod"
            @time out = runModels!(out, f, forward_models, tem_helpers)
            @show "out"
            @time setOuputT!(loc_output, out, tem_variables, ts, dtypes, dtypes_list)
            # @code_warntype setOuputT!(loc_output, out, tem_variables, ts, dtypes, dtypes_list)
        else
            f = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_t)
            # f = getForcingForTimeStep(forcing, ts)#::ftype
            out = runModels!(out, f, forward_models, tem_helpers)#::otype
            setOuputT!(loc_output, out, tem_variables, ts, dtypes, dtypes_list)
        end
    end
end



function coreEcosystem!(loc_output, approaches, loc_forcing, tem_helpers, tem_spinup, tem_models, tem_variables, land_init, dtypes, dtypes_list)
    land_one_type = get_dtype(dtypes, dtypes_list, :land_one_type)
    loc_forcing_type = get_dtype(dtypes, dtypes_list, :loc_forcing_type)
    land_prec = runPrecompute!(land_init::land_one_type, getForcingForTimeStep(loc_forcing, 1), approaches, tem_helpers)::land_one_type
    land_spin_now = land_prec
    # push!(Sindbad.error_catcher, typeof(land_prec))    

    if tem_helpers.run.runSpinup
        land_spin_now = runSpinup(approaches, loc_forcing::loc_forcing_type, land_spin_now, tem_helpers, tem_spinup, tem_models, land_one_type; spinup_forcing=nothing)
    end
    # push!(Sindbad.error_catcher, typeof(land_spin_now))    
    time_steps = getForcingTimeSize(loc_forcing::loc_forcing_type)
    timeLoopForward!(loc_output, approaches, loc_forcing, land_spin_now, tem_variables, tem_helpers, time_steps, dtypes, dtypes_list)
end

function doOneLocation(outcubes::AbstractArray, approaches, forcing, tem, additionaldims, loc_names)
    loc_forcing, loc_output = getLocData(outcubes, forcing, additionaldims, loc_names)
    loc_output_type = typeof(loc_output)
    loc_forcing_type = typeof(loc_forcing)
    land_init = createLandInit(tem);
    land_init_type = typeof(land_init);
    land_prec = runPrecompute!(land_init, getForcingForTimeStep(loc_forcing, 1), approaches, tem.helpers)
    land_prec_type = typeof(land_prec)
    f = getForcingForTimeStep(loc_forcing, 1)
    # @code_warntype getForcingForTimeStep(loc_forcing, 1)
    forcing_one_type = typeof(f)
    land_one = runModels!(land_prec, f, approaches, tem.helpers);
    land_one_type = typeof(land_one)
    dtypesN =(; land_init_type=land_init_type, land_prec_type=land_prec_type, land_one_type=land_one_type, loc_forcing_type=loc_forcing_type, loc_output_type=loc_output_type, forcing_one_type=forcing_one_type)
    dtypes_list = Symbol.(keys(dtypesN) |> collect)
    dtypes = DataType[]
    for dv in dtypes_list
        push!(dtypes, dtypesN[dv])
    end

    return land_one, dtypes, dtypes_list   
end

function get_dtype(dtypes, dtypes_list, field::Symbol)
    return dtypes[first(findall(dtypes_list .== field))]
end


"""
prepRunEcosystem(approaches, forcing, land_init, tem)
"""
function prepRunEcosystem(outcubes::AbstractArray, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple)
    loopvars = keys(tem.helpers.run.loop) |> collect
    additionaldims = setdiff(loopvars,[:time])::Vector{Symbol}
    spacesize = values(tem.helpers.run.loop[additionaldims])::Tuple
    spaceLocs = vec(Iterators.product(Base.OneTo.(spacesize)...) |> collect)::Vector{NTuple{length(tem.helpers.run.loop)-1,Int}}

    land_one, dtypes, dtypes_list = doOneLocation(outcubes::AbstractArray, approaches, forcing, tem, additionaldims, spaceLocs[1])
    l_init_threads = [deepcopy(land_one) for _ in 1:Threads.nthreads()]
    return additionaldims, spaceLocs, l_init_threads, dtypes, dtypes_list
end


"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes::AbstractArray, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple)
    additionaldims, spaceLocs, l_init_threads, dtypes, dtypes_list = prepRunEcosystem(outcubes, approaches, forcing, tem)
    parallelizeIt(outcubes, approaches, forcing, tem.helpers, tem.spinup, tem.models, Val(tem.variables), additionaldims, l_init_threads, dtypes, dtypes_list, spaceLocs, tem.helpers.run.parallelization)

    # GC.gc(true)
    # GC.enable(true)
end


"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes::AbstractArray, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, additionaldims::Vector{Symbol}, spaceLocs::Vector, l_init_threads, dtypes::Vector{DataType}, dtypes_list::Vector{Symbol})
    parallelizeIt(outcubes, approaches, forcing, tem.helpers, tem.spinup, tem.models, Val(tem.variables), additionaldims, l_init_threads, dtypes, dtypes_list, spaceLocs, tem.helpers.run.parallelization)
end

function parallelizeIt(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, additionaldims, l_init, dtypes, dtypes_list, spaceLocs, ::Val{:threads})
    Threads.@threads for i = eachindex(spaceLocs)
        loc_names = spaceLocs[i]
        ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, additionaldims, loc_names, l_init[Threads.threadid()], dtypes, dtypes_list)
        end
    end    

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function parallelizeIt(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, additionaldims, l_init, dtypes, dtypes_list, spaceLocs, ::Val{:qbmap})    
    qbmap(spaceLocs) do loc_names
        ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, additionaldims, loc_names, l_init[Threads.threadid()], dtypes, dtypes_list)
    end
end