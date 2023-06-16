export runEcosystem!, prepRunEcosystem
export ecoLoc!
export getLocData

function getLocData(outcubes, forcing, loc_space_map)
    loc_forcing = map(forcing) do a
        view(a; loc_space_map...)
    end
    # ar_inds = last.(loc_space_map)
    ar_inds = Tuple(last.(loc_space_map))

    loc_output = map(outcubes) do a
        getArrayView(a, ar_inds)
    end
    return loc_forcing, loc_output
end



function get_loc_out!(outcubes, ar_inds, loc_output)
    for i in eachindex(outcubes)
        loc_output[i] = getArrayView(outcubes[i], ar_inds)
    end
end


@generated function get_loc_forcing!(forcing, ::Val{forc_vars}, ::Val{s_names}, loc_forcing, s_locs) where {forc_vars, s_names}
    output = quote
    end
    foreach(forc_vars) do forc
            push!(output.args,Expr(:(=),:d, Expr(:.,:forcing, QuoteNode(forc))))
            s_ind = 1
            foreach(s_names) do s_name
                expr = Expr(:(=), :d, Expr(:call, :view, Expr(:parameters, Expr(:call, :(=>), QuoteNode(s_name), Expr(:ref, :s_locs, s_ind))), :d))
                push!(output.args, expr)
                s_ind += 1
            end
            push!(output.args, Expr(:(=), :loc_forcing, Expr(:macrocall, Symbol("@set"), :(#= none:1 =#), Expr(:(=), Expr(:., :loc_forcing, QuoteNode(forc)), :d))))
    end
    output
end


function ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, loc_space_names, loc_space_ind, loc_forcing, loc_output, land_init, f_one)
    get_loc_out!(outcubes, loc_space_ind, loc_output);
    get_loc_forcing!(forcing, Val(keys(f_one)), Val(loc_space_names), loc_forcing, loc_space_ind);
    coreEcosystem!(loc_output, approaches, loc_forcing, tem_helpers, tem_spinup, tem_models, tem_variables, land_init, f_one)
end


function get_view(ar, val::AbstractArray, ts::Int64)
    view(ar, ts, 1:length(val))
end

function get_view(ar, val::Real, ts::Int64)
    view(ar, ts)
end

function fill_it!(ar, val, ts::Int64)
    data_ts = get_view(ar, val, ts)
    data_ts .= val
    # data_ts .= Sindbad.ForwardDiff.value(val)
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
    if tem.helpers.run.debugit
        Sindbad.eval(:(error_catcher = []))    
        push!(Sindbad.error_catcher, land_one)
        pprint(land_one)
    end
    return land_one, f_one  
end



"""
prepRunEcosystem(approaches, forcing, land_init, tem)
"""
function prepRunEcosystem(outcubes::AbstractArray, land_init, approaches::Tuple, forcing::NamedTuple, forcing_sizes::NamedTuple, tem::NamedTuple)
    loopvars = keys(forcing_sizes) |> collect
    additionaldims = setdiff(loopvars,[:time])::Vector{Symbol}
    spacesize = values(forcing_sizes[additionaldims])::Tuple
    loc_space_maps = vec(Iterators.product(Base.OneTo.(spacesize)...) |> collect)::Vector{NTuple{length(forcing_sizes)-1,Int}}

    loc_space_maps = map(loc_space_maps) do loc_names
        map(zip(loc_names,additionaldims)) do (loc_index,lv)
            lv=>loc_index
        end
    end
    loc_space_maps = Tuple(loc_space_maps)
    allNans = Bool[]
    for i in eachindex(loc_space_maps)
        loc_forcing, _ = getLocData(outcubes, forcing, loc_space_maps[i]) #312
        push!(allNans, all(isnan, loc_forcing[1]))
    end
    loc_forcing, loc_output = getLocData(outcubes, forcing, loc_space_maps[1]) #312
    loc_space_maps = loc_space_maps[allNans .== false]
    land_one, f_one  = doOneLocation(outcubes, land_init, approaches, forcing, tem, loc_space_maps[1])
    loc_forcings = Tuple([loc_forcing for _ in 1:Threads.nthreads()])
    loc_outputs = Tuple([loc_output for _ in 1:Threads.nthreads()])
    land_init_space = Tuple([deepcopy(land_one) for _ in 1:length(loc_space_maps)])
    loc_space_names = Tuple(first.(loc_space_maps[1]));
    loc_space_inds = Tuple([Tuple(last.(loc_space_map)) for loc_space_map in loc_space_maps])
    return loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one
end


"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes::AbstractArray, land_init::NamedTuple, approaches::Tuple, forcing::NamedTuple, forcing_sizes::NamedTuple, tem::NamedTuple)
    loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one = prepRunEcosystem(outcubes, land_init, approaches, forcing, forcing_sizes, tem)
    parallelizeIt(outcubes, approaches, forcing, tem.helpers, tem.spinup, tem.models, Val(tem.variables), loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one, tem.helpers.run.parallelization)
end

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function runEcosystem!(outcubes::AbstractArray, approaches::Tuple, forcing::NamedTuple, tem::NamedTuple, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one)
    parallelizeIt(outcubes, approaches, forcing, tem.helpers, tem.spinup, tem.models, Val(tem.variables), loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one, tem.helpers.run.parallelization)
end

function parallelizeIt(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one, ::Val{:threads})
    Threads.@threads for i = eachindex(loc_space_inds)
        ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, loc_space_names, loc_space_inds[i], loc_forcings[Threads.threadid()], loc_outputs[Threads.threadid()], land_init_space[i], f_one)
        end
end    

"""
runEcosystem(approaches, forcing, land_init, tem)
"""
function parallelizeIt(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, loc_space_names, loc_space_inds, loc_forcings, loc_outputs, land_init_space, f_one, ::Val{:qbmap}) 
    spI = 1
    qbmap(loc_space_inds) do loc_space_ind
        ecoLoc!(outcubes, approaches, forcing, tem_helpers, tem_spinup, tem_models, tem_variables, loc_space_names, loc_space_ind, loc_forcings[Threads.threadid()], loc_outputs[Threads.threadid()], land_init_space[spI], f_one)
        spI += 1
    end
end