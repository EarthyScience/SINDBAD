using Sindbad, ForwardSindbad, OptimizeSindbad
using YAXArrays, Zarr, YAXArrayBase, AxisKeys
using Flux, Optimisers, Zygote
using ForwardDiff
using Random
using ProgressMeter
using Accessors
using ConstructionBase
using Statistics

function new_ar(ar)
    map(ar) do a
        if typeof(a) <: ForwardDiff.Dual
            return a.value
        else
            return a
        end
    end
end


function get_trues(ŷ, yσ, y)
    return (.!isnan.(y .* yσ .* ŷ)) # ::KeyedArray{Bool, 1, NamedDimsArray{(:time,), Bool, 1, BitVector}, Base.RefValue{Vector{DateTime}}}
end

function loss_oo(ŷ::AbstractArray, y::AbstractArray, ::Val{:mse}, idxs)
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end

function get_loc_loss(loc_obs,
    loc_output,
    newApproaches,
    loc_forcing,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    loc_land_init,
    f_one)
    coreEcosystem!(loc_output,
        newApproaches,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        Val(tem_variables),
        #tem_variables,
        loc_land_init,
        f_one)
    model_data = (; Pair.(out_variables, loc_output)...)
    lossVec = getLossVectorArray(loc_obs, model_data, tem_optim)
    return combineLossArray(lossVec, Val(tem_optim.multiConstraintMethod)) #sum(lossVec) Val{:sum}()
end
    #model_data = loc_output
#    cost_options = [Pair(:gpp, Val(:mse))]
#=
    lossVec = map(cost_options) do p
                obsV = first(p)
                s_metric = last(p) 
                y = get_y(loc_obs, obsV)
                ŷ = loc_output[1]
                ŷ = size(ŷ,2)==1 ? get_ŷn(ŷ) : ŷ
                yσ = get_y(loc_obs, :gpp_σ)
                idxs = get_trues(ŷ, yσ, y)
                metr = loss_oo(ŷ, y, s_metric, idxs)
                if isnan(metr)
                   metr = oftype(metr, 1e19) # buggy?
                end
                metr
            end

=#

function loc_loss(upVector,
    loc_space_ind,
    loc_land_init,
    loc_output,
    loc_forcing,
    loc_obs,
    v_loc_space_names,
    output,
    forc,
    obs,
    tblParams,
    forward,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    f_one)

    getLocOutput!(output.data, loc_space_ind, loc_output)
    getLocForcing!(forc, Val(keys(f_one)), v_loc_space_names, loc_forcing, loc_space_ind)
    getLocObs!(obs, Val(keys(obs)), v_loc_space_names, loc_obs, loc_space_ind)
    newApproaches = Tuple(updateModelParametersType(tblParams, forward, upVector))
    return get_loc_loss(loc_obs,
        loc_output,
        newApproaches,
        loc_forcing,
        tem_helpers,
        tem_spinup,
        tem_models,
        tem_variables,
        tem_optim,
        out_variables,
        loc_land_init,
        f_one)

end

include("setup_simple.jl")

loc_space_maps,
loc_space_names,
loc_space_inds,
loc_forcings,
loc_outputs,
land_init_space,
f_one,
tblParams,
forward,
tem_helpers,
tem_spinup,
tem_models,
tem_variables,
tem_optim,
out_variables,
output,
forc,
obs = setup_simple();

#cost_options = tem_optim.costOptions


site_location = loc_space_maps[1];

function getLocDataObsN(outcubes, forcing, obs, loc_space_map)
    loc_forcing = map(forcing) do a
        return view(a; loc_space_map...)
    end
    loc_obs = map(obs) do a
        return view(a; loc_space_map...)
    end
    ar_inds = last.(loc_space_map)

    loc_output = map(outcubes) do a
        return getArrayView(a, ar_inds)
    end
    return loc_forcing, loc_output, loc_obs
end

loc_forcing, loc_output, loc_obs = getLocDataObsN(output.data, forc, obs, site_location);

loc_space_ind = loc_space_inds[1]
loc_land_init = land_init_space[1];
loc_output = loc_outputs[1]
loc_forcing = loc_forcings[1]

#tem_optim_new = (; tem_optim..., costOptions=(; tem_optim.costOptions..., variable = [:gpp], costMetric = [Val(:mse)]))

args = (;
    output,
    forc,
    obs,
    tblParams,
    forward,
    tem_helpers,
    tem_spinup,
    tem_models,
    tem_variables,
    tem_optim,
    out_variables,
    f_one,
    );

args_txyz = (;
    loc_output,
    loc_forcing,
    loc_obs,
    v_loc_space_names=Val(loc_space_names),
);


loc_loss(
    tblParams.defaults,
    loc_space_ind, 
    loc_land_init,
    args_txyz...,
    args...)

@code_warntype loc_loss(
    tblParams.defaults,
    loc_space_ind, 
    loc_land_init,
    args_txyz...,
    args...)


@time loc_loss(
    tblParams.defaults,
    loc_space_ind, 
    loc_land_init,
    args_txyz...,
    args...)

all_approaches = nameof.(typeof.(tem_models.forward)) # a better way to do this?

tblParams2 = Sindbad.@Select(names, modelsApproach)(tblParams)

@code_warntype updateModelParametersType(tblParams, forward, tblParams.defaults)

@time updateModelParametersType(tblParams, forward, tblParams.defaults*rand());



#=
reconstruct_model(::rainSnow_Tair, args...;kwargs...) = rainSnow_Tair(args...;kwargs...)
o = rainSnow_Tair()
reconstruct_model(o, 1f0)
xtpl = [1.0, [1f0]]
@code_warntype ntuple(i->xtpl[i], 2)
@code_warntype Tuple([1, [1f0]])
typeof(Tuple([1, [1f0]]))
=#
forward = tem_models.forward
@time newforward = nnpdateModelParametersType(tblParams, forward, tblParams.defaults);


# test gradient
function fdiff_grads(f, v, loc_space_ind, loc_land_init, args_txyz, args)
    gf(v) = f(v, loc_space_ind, loc_land_init, args_txyz..., args...)
    return ForwardDiff.gradient(gf, v)
end
 
@code_warntype fdiff_grads(loc_loss, tblParams.defaults,
    loc_space_ind,
    loc_land_init,
    args_txyz,
    args)

@time fdiff_grads(loc_loss, tblParams.defaults,
    loc_space_ind,
    loc_land_init,
    args_txyz,
    args)


function fdiff_grads!(f, v, n, loc_space_ind, loc_land_init, args_txyz, args)
    gf(v) = f(v, loc_space_ind, loc_land_init, args_txyz..., args...)
    cfg_n = ForwardDiff.GradientConfig(gf, v, ForwardDiff.Chunk{n}());
    out = similar(v)
    ForwardDiff.gradient!(out, gf, v, cfg_n)
    return out
end
GC.gc()
@time fdiff_grads!(loc_loss, tblParams.defaults,
    20,
    loc_space_ind,
    loc_land_init,
    args_txyz, 
    args);

function name_to_ind(site_name, sites_forcing)
    site_id_forc = findall(x -> x == site_name, sites_forcing)[1]
    return (site_id_forc, )
end

function grads_bss!(
    f_grads,
    up_params,
    xbatch,
    n_chunk,
    sites_f,
    land_init_space,
    loc_loss,
    is_logging,
    args_txyz,
    args)

    p = Progress(length(xbatch); desc="Computing batch grads...", color=:yellow, enabled =is_logging)
    for (site_index, site_name) ∈ enumerate(xbatch)
        x_params = up_params(; site=site_name)
        v = getParamsAct(x_params, args.tblParams)
        loc_space_ind = name_to_ind(site_name, sites_f)
        loc_land_init = land_init_space[loc_space_ind[1]]
        f_grads[:, site_index] = 
            fdiff_grads!(loc_loss, v,
                n_chunk,
                loc_space_ind,
                loc_land_init,
                args_txyz, 
                args);
        next!(p; showvalues=[(:site_name, site_name), (:loc_space_ind, loc_space_ind)])
    end
end

# gen synth obs
n_params = sum(tblParams.is_ml)
n_neurons = 32

include("gen_synth_obs.jl");

f_grads = zeros(Float32, n_params, 20)
xbatch = cov_sites[1:20]

grads_bss!(
    f_grads,
    sites_parameters,
    xbatch,
    20,
    sites_f,
    land_init_space,
    loc_loss,
    true,
    args_txyz,
    args)

# grads_args = (; tblParams, sites_f, land_init_space, output, forc, obs_synt, forward, helpers, spinup, models, out_vars, f_one)
function get_∇params(xfeatures, re, flat, xbatch,
    n_params,
    n_bs_sites,
    n_chunk,
    sites_f,
    land_init_space,
    loc_loss,
    args_txyz,
    args)

    f_grads = zeros(Float32, n_params, n_bs_sites)
    x_feat = xfeatures(; site=xbatch)
    inst_params, pb = Zygote.pullback((x, p) -> re(p)(x), x_feat, flat)
    grads_bss!(f_grads, inst_params, xbatch,
        n_chunk,
        sites_f,
        land_init_space,
        loc_loss,
        false,
        args_txyz,
        args)
    _, ∇params = pb(f_grads)
    return ∇params
end

nn_args = (; n_bs_feat, n_neurons, n_params, extra_layer=1, nn_opt = Optimisers.Adam(),)

function init_ml_nn(n_bs_feat, n_neurons, n_params, extra_hlayers, nn_opt=Optimisers.Adam())
    ml_model = ml_nn(n_bs_feat, n_neurons, n_params; extra_hlayers=extra_hlayers)
    flat, re = Optimisers.destructure(ml_model)
    opt_state = Optimisers.setup(nn_opt, flat)
    return flat, re, opt_state
end

flat, re, opt_state = init_ml_nn(nn_args...)

get_∇params(xfeatures, re, flat, xbatch,
    n_params,
    20,
    20,
    sites_f,
    land_init_space,
    loc_loss,
    args_txyz,
    args)

x_args = (; shuffle=true, bs=16, sites)

using Base.Iterators: repeated, partition
using Random

function shuffle_sites(sites; seed=123)
    Random.seed!(seed)
    rand_names = randperm(length(sites))
    return sites[rand_names]
end

function bs_iter(n; batch_size=32)
    return partition(1:n, batch_size)
end

#x_args = (; shuffle=true, bs=16, sites)
function shuffle_indxs(sites, n_bs_sites, mb_idxs; seed=1)
    s_sites = shuffle_sites(sites; seed=seed)
    xbatches = [s_sites[p] for p ∈ mb_idxs if length(p) == n_bs_sites]
    return xbatches
end

function nn_machine(nn_args, x_args, xfeatures,
    sites_f,
    land_init_space,
    loc_loss,
    args_txyz,
    args; 
    nepochs=10)

    flat, re, opt_state = init_ml_nn(nn_args...)
    mb_idxs = bs_iter(length(x_args.sites); batch_size=x_args.bs)
    xbatches = shuffle_indxs(x_args.sites, x_args.bs, mb_idxs; seed=1)
    new_sites = reduce(vcat, xbatches)
    tot_loss = fill(NaN32, length(new_sites), nepochs)

    for epoch ∈ 1:nepochs
        p = Progress(length(xbatches); desc="Computing batch grads...")
        xbatches =
            x_args.shuffle ? shuffle_indxs(x_args.sites, x_args.bs, mb_idxs; seed=epoch) :
            xbatches
        for (batch_id, xbatch) ∈ enumerate(xbatches)
            ∇params = get_∇params(xfeatures, re, flat, xbatch, nn_args.n_params, x_args.bs,
                20,
                sites_f,
                land_init_space,
                loc_loss,
                args_txyz,
                args)

            Optimisers.update!(opt_state, flat, ∇params)
            next!(p; showvalues=[(:epoch, epoch), (:batch_id, batch_id)])
        end
        up_params = re(flat)(xfeatures(; site=new_sites))
        tot_loss[:, epoch] = get_site_losses(up_params, new_sites, sites_f, land_init_space,
            args_txyz, args)
    end
    return tot_loss
end

function get_site_losses(up_params,
    new_sites,
    sites_f,
    land_init_space,
    args_txyz,
    args)
    tot_loss = fill(NaN32, length(new_sites))
    #Threads.@threads for s_id ∈ eachindex(new_sites)
    for s_id ∈ eachindex(new_sites)
        site_name = new_sites[s_id]
        x_params = up_params(; site=site_name)
        v = getParamsAct(x_params, args.tblParams)
        loc_space_ind = name_to_ind(site_name, sites_f)
        loc_land_init = land_init_space[loc_space_ind[1]]
        tot_loss[s_id] = loc_loss(v, loc_space_ind, loc_land_init, args_txyz..., args...) # maybe a bug? threads scope
    end
    return tot_loss
end

nn_machine(nn_args, x_args, xfeatures,
    sites_f,
    land_init_space,
    loc_loss,
    args_txyz,
    args; 
    nepochs=3)

function mysum(mv::KeyedArray{T}) where T
    s=0
    for i in eachindex(mv)
        s+=mv[i]
    end
    return s
end

using Dates, ForwardDiff, AxisKeys
r = rand(Float32, 4)
r[1] = NaN32    
ka = KeyedArray(r; i =Date(today()):Date(today()+Day(3)) )
ar = Union{Float32, ForwardDiff.Dual}[1f0,2f0, ForwardDiff.Dual(NaN32), 2f0]
idx_f(ar,ka) = (.!isnan.(ar .* ka))
idxs = idx_f(ar,ka)

@code_warntype idx_f(ar,ka)

function ka_ar_unstable(ka, ar,idxs)
    return abs2.(ka[idxs] .- ar[idxs])
end

@code_warntype ka_ar_unstable(ka, ar, idxs)


o_ka = ka_ar_unstable(ka, ar, idxs)

@code_warntype sum(o_ka)


function all_pack(ar, ka)
    idxs = idx_f(ar,ka) # this needs to be called here because, 'ar' and 'ka' 
                        #are comming from an outer loop.
    vals = ka_ar_unstable(ka, ar,idxs)
    return sum(vals)
end

@code_warntype all_pack(ar, ka)

function ka_ar_unstable(ka, ar)
    idxs = (.!isnan.(ar .* ka))
    return abs2.(ka[idxs] .- ar[idxs])
end

@code_warntype ka_ar_unstable(ar, ka)










@code_warntype idx_f(ar,ka)

function ka_ar_unstable(ka, ar)
    idxs = (.!isnan.(ar .* ka))
    return sum(abs2.(ka[idxs] .- ar[idxs]))
end

@code_warntype ka_ar_unstable(ka, ar)



ka_ar_unstable(ka, ar, idxs) |> typeof


idxs = (.!isnan.(ar .* ka))
o_val = ka[idxs] .- ar[idxs]

typeof(o_val) <: AbstractVector


ŷ_ka = KeyedArray(ŷ .|> Float32; t = 1:length(ŷ))

ar =  Union{Float32, ForwardDiff.Dual}[1f0,2f0, ForwardDiff.Dual(NaN32), 2f0]

function new_ar(ar)
    map(ar) do a
        if typeof(a) <: ForwardDiff.Dual
            return a.value
        else
            return a
        end
    end
end
@code_warntype new_ar(ar)
new_ar(ar)




using Dates, ForwardDiff, AxisKeys
ar = Union{Float32, ForwardDiff.Dual}[1f0,2f0, ForwardDiff.Dual(NaN32), 2f0]

function get_dval(a::ForwardDiff.Dual{Nothing, Float32, 0})
    return a.value
end

@code_warntype get_dval(ar[3])

function get_dval(a::T) where T<:Float32
    return a
end

@code_warntype get_dval(ar[1])
@code_warntype get_dval(ar[3])

function new_ar_t(ar)
    map(ar) do a
        get_dval(a)
    end
end

@code_warntype new_ar_t(ar)

new_ar_t(ar)
