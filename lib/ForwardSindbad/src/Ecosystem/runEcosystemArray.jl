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
    inds = nothing
    loc_forcing = map(forcing) do a
        inds = map(zip(loc_names,additionaldims)) do (loc_index,lv)
            lv=>loc_index
        end
        view(a;inds...)
    end

    loc_output = map(outcubes) do a
        inds2 = map(zip(loc_names,additionaldims)) do (loc_index,lv)
            loc_index
        end
        # @show size(a), inds, typeof(inds)
        getArrayView(a, inds2)
    end
    return loc_forcing, loc_output, inds
end

function getLocData(outcubes::AbstractArray, forcing, additionaldims, loc_names, loc_forcing, loc_output, loc_inds)
    loc_inds_index = 1
    for (loc_index, lv) in zip(loc_names, additionaldims)
        # @show loc_inds[loc_inds_index], lv => loc_index
        loc_inds[loc_inds_index] = lv => loc_index
        loc_inds_index += 1
    end

    for loc_forcing_var = keys(forcing)
        view_a = view(forcing[loc_forcing_var]; loc_inds...)
        loc_forcing = @set loc_forcing[loc_forcing_var] = view_a
    end
    
    for loc_output_index = eachindex(outcubes)
        view_a = getArrayView(outcubes[loc_output_index], last.(loc_inds))
        loc_output[loc_output_index] = view_a
    end
    
    return loc_forcing, loc_output
end


# @generated function getLocData(outcubes::AbstractArray, forcing, additionaldims, loc_names, loc_forcing, loc_output, loc_inds)
#     output = quote
#     loc_inds_index = 1
#     end
#     var_index = 1
#         foreach(keys(TEM)) do group
#         foreach(TEM[group]) do k
#             push!(output.args,Expr(:(=),:data_l,Expr(:.,Expr(:.,:land,QuoteNode(group)),QuoteNode(k))))
#                     push!(output.args,quote
#                 data_o = outputs[$var_index]
#                 fill_it!(data_o, data_l, ts)
#             end)
#             var_index += 1
#         end
#     end
#     output
# end
# function getLocData(outcubes::AbstractArray, forcing, additionaldims, loc_names)
#     inds = map(zip(loc_names,additionaldims)) do (loc_index,lv)
#         lv=>loc_index
#     end
#     # @show inds, values(inds)
#     loc_forcing = map(forcing) do a
#         view(a;inds...)
#     end
#     loc_output = map(outcubes) do a
#         getArrayView(a, last.(inds))
#     end
#     # @show keys(loc_forcing), typeof(loc_output), size(loc_output)
#     return loc_forcing, loc_output
# end


function ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, additionaldims, loc_names, land_init, dtypes, dtypes_list, f_1, loc_forcing, loc_output, loc_inds)
    # loc_forcing, loc_output, _ = getLocData(outcubes, forcing, additionaldims, loc_names)

    loc_forcing::get_dtype(dtypes, dtypes_list, :loc_forcing_type), loc_output::get_dtype(dtypes, dtypes_list, :loc_output_type), loc_x = getLocData(outcubes, forcing, additionaldims, loc_names) #312
    # loc_forcing2::get_dtype(dtypes, dtypes_list, :loc_forcing_type), loc_output2::get_dtype(dtypes, dtypes_list, :loc_output_type) = getLocData(outcubes, forcing, additionaldims, loc_names, loc_forcing, loc_output, loc_inds) #312
    # @time loc_forcing, loc_output = getLocData(outcubes, forcing, additionaldims, loc_names, loc_forcing, loc_output, loc_inds) #312
    # @show loc_forcing == loc_forcing2, loc_output.==loc_output2
    coreEcosystem!(loc_output, approaches, loc_forcing, tem_helpers, tem_spinup, tem_models, tem_variables, land_init, dtypes, dtypes_list, f_1)
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

function timeLoopForward!(loc_output, forward_models, forcing, out, tem_variables, tem_helpers, time_steps::Int64, dtypes, dtypes_list, f_1)
    ftype = get_dtype(dtypes, dtypes_list, :forcing_one_type)
    # f_t = Array{Union{KeyedArray, AbstractFloat}}(undef, length(forcing))
    f_t = f_1::ftype

    debugit = true
    debugit = false
    if debugit
        time_steps = 1
    end
    for ts = 1:time_steps
        if debugit
            @show "forc"
            @time f = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_t)
            @show "mod"
            @time out = runModels!(out, f, forward_models, tem_helpers)
            @show "out"
            @time setOuputT!(loc_output, out, tem_variables, ts, dtypes, dtypes_list)
            @show "-------------"
            # @code_warntype setOuputT!(loc_output, out, tem_variables, ts, dtypes, dtypes_list)
        else
            f = getForcingForTimeStep(forcing, Val(keys(forcing)), ts, f_1)
            out = runModels!(out, f, forward_models, tem_helpers)#::otype
            setOuputT!(loc_output, out, tem_variables, ts, dtypes, dtypes_list)
        end
    end
end



function coreEcosystem!(loc_output, approaches, loc_forcing, tem_helpers, tem_spinup, tem_models, tem_variables, land_init, dtypes, dtypes_list, f_1)
    land_one_type = get_dtype(dtypes, dtypes_list, :land_one_type)
    land_spin_now = land_init

    if tem_helpers.run.runSpinup
        land_spin_now = runSpinup(approaches, loc_forcing, land_spin_now, tem_helpers, tem_spinup, tem_models, land_one_type, f_1; spinup_forcing=nothing)
    end
    time_steps = getForcingTimeSize(loc_forcing, Val(keys(loc_forcing)))
    timeLoopForward!(loc_output, approaches, loc_forcing, land_spin_now, tem_variables, tem_helpers, time_steps, dtypes, dtypes_list, f_1)
end

function doOneLocation(outcubes::AbstractArray, approaches, forcing, tem, additionaldims, loc_names)
    loc_forcing, loc_output, loc_inds = getLocData(outcubes, forcing, additionaldims, loc_names)
    loc_output_type = typeof(loc_output)
    loc_forcing_type = typeof(loc_forcing)
    land_init = createLandInit(tem);
    land_init_type = typeof(land_init);
    land_prec = runPrecompute!(land_init, getForcingForTimeStep(loc_forcing, 1), approaches, tem.helpers)
    land_prec_type = typeof(land_prec)
    f_1 = getForcingForTimeStep(loc_forcing, 1)
    forcing_one_type = typeof(f_1)
    land_one = runModels!(land_prec, f_1, approaches, tem.helpers);
    land_one_type = typeof(land_one)
    dtypesN =(; land_init_type=land_init_type, land_prec_type=land_prec_type, land_one_type=land_one_type, loc_forcing_type=loc_forcing_type, loc_output_type=loc_output_type, forcing_one_type=forcing_one_type)
    dtypes_list = Symbol.(keys(dtypesN) |> collect)
    dtypes = DataType[]
    for dv in dtypes_list
        push!(dtypes, dtypesN[dv])
    end

    return land_one, dtypes, dtypes_list, f_1, loc_forcing, loc_output, loc_inds   
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
    space_locs = vec(Iterators.product(Base.OneTo.(spacesize)...) |> collect)::Vector{NTuple{length(tem.helpers.run.loop)-1,Int}}

    allNans = Bool[]
    for i in eachindex(space_locs)
        loc_forcing, loc_output = getLocData(outcubes, forcing, additionaldims, space_locs[i]) #312
        push!(allNans, all(isnan, loc_forcing[1]))
    end
    space_locs = space_locs[allNans .== false]
    land_one, dtypes, dtypes_list, f_1, loc_forcing, loc_output, loc_inds  = doOneLocation(outcubes::AbstractArray, approaches, forcing, tem, additionaldims, space_locs[1])
    l_init_threads = [deepcopy(land_one) for _ in 1:Threads.nthreads()]
    return additionaldims, space_locs, l_init_threads, dtypes, dtypes_list, f_1, loc_forcing, loc_output, loc_inds 
end


"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes::AbstractArray, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple)
    additionaldims, space_locs, l_init_threads, dtypes, dtypes_list, f_1, loc_forcing, loc_output, loc_inds = prepRunEcosystem(outcubes, approaches, forcing, tem)
    parallelizeIt(outcubes, approaches, forcing, tem.helpers, tem.spinup, tem.models, Val(tem.variables), additionaldims, l_init_threads, dtypes, dtypes_list, space_locs, f_1, loc_forcing, loc_output, loc_inds, tem.helpers.run.parallelization)
end

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes::AbstractArray, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, additionaldims::Vector{Symbol}, space_locs::Vector, l_init_threads, dtypes::Vector{DataType}, dtypes_list::Vector{Symbol}, f_1, loc_forcing, loc_output, loc_inds)
    parallelizeIt(outcubes, approaches, forcing, tem.helpers, tem.spinup, tem.models, Val(tem.variables), additionaldims, l_init_threads, dtypes, dtypes_list, space_locs, f_1, loc_forcing, loc_output, loc_inds, tem.helpers.run.parallelization)
end

function parallelizeIt(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, additionaldims, l_init, dtypes, dtypes_list, space_locs, f_1, loc_forcing, loc_output, loc_inds, ::Val{:threads})
    Threads.@threads for i = eachindex(space_locs)
        loc_names = space_locs[i]
        ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, additionaldims, loc_names, l_init[Threads.threadid()], dtypes, dtypes_list, f_1, loc_forcing, loc_output, loc_inds)
        end
end    

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function parallelizeIt(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, additionaldims, l_init, dtypes, dtypes_list, space_locs, f_1, loc_forcing, loc_output, loc_inds, ::Val{:qbmap})    
    qbmap(space_locs) do loc_names
        ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, additionaldims, loc_names, l_init[Threads.threadid()], dtypes, dtypes_list, f_1, loc_forcing, loc_output, loc_inds)
    end
end