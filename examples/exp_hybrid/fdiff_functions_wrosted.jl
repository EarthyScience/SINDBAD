include("pkgs.jl")
include("new_fdiff.jl")
include("setup_wrosted.jl")
#@show info.tem.helpers.pools
n_neurons = 32

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
obs = setup_wrosted();



n_params = sum(tblParams.is_ml)

site_location = loc_space_maps[1];
loc_space_ind = loc_space_inds[1];
loc_land_init = land_init_space[1];
loc_output = loc_outputs[1]
loc_forcing = loc_forcings[1]

getLocOutput!(output.data, loc_space_ind, loc_output)
getLocForcing!(forc, Val(keys(f_one)), Val(loc_space_names), loc_forcing, loc_space_ind)
getLocObs!(obs, Val(keys(obs)), Val(loc_space_names), loc_obs, loc_space_ind)


@generated function getLocObs!(obs,
# function getLocObs!(obs,
        ::Val{obs_vars},
    ::Val{s_names},
    loc_obs,
    s_locs) where {obs_vars,s_names}
    output = quote end
    foreach(obs_vars) do obsv
        push!(output.args, Expr(:(=), :d, Expr(:., :obs, QuoteNode(obsv))))
        s_ind = 1
        foreach(s_names) do s_name
            expr = Expr(:(=),
                :d,
                Expr(:call,
                    :view,
                    Expr(:parameters,
                        Expr(:call, :(=>), QuoteNode(s_name), Expr(:ref, :s_locs, s_ind))),
                    :d))
            push!(output.args, expr)
            return s_ind += 1
        end
        return push!(output.args,
            Expr(:(=),
                :loc_obs,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., :loc_obs, QuoteNode(obsv)), :d)))) #= none:1 =#
    end
    return output
end




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
    f_type
    );

@time loc_loss(tblParams.defaults, site_location, loc_land_init, args...)
@code_warntype loc_loss(tblParams.defaults, site_location, loc_land_init, args...)
@time fdiff_grads(loc_loss, tblParams.defaults, site_location, loc_land_init, args)
@code_warntype getLocDataObsN(output.data, forc, obs, site_location);
@time fdiff_grads(loc_loss, tblParams.defaults, site_location, loc_land_init, args)
@code_warntype fdiff_grads(loc_loss, tblParams.defaults, site_location, loc_land_init, args)


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

site_location = loc_space_maps[1];
loc_space_ind = loc_space_inds[1];
loc_land_init = land_init_space[1];
loc_output = loc_outputs[1]
loc_forcing = loc_forcings[1]
#mods = tem_models.forward

#dualDefs = ForwardDiff.Dual{tem_helpers.numbers.numType}.(tblParams.defaults);
#mods = updateModelParametersType(tblParams, tem_models.forward, dualDefs);
#mod_type = typeof(mods)
#mods = [updateModelParametersType(tblParams, (m,), dualDefs) for m in tem_models.forward]

@code_warntype loc_loss_f(tblParams.defaults, loc_space_ind, 
    loc_output,
    loc_forcing,
    Val(loc_space_names),
    loc_obs,
    loc_land_init,
    args...)

@time loc_loss_f(tblParams.defaults, loc_space_ind, 
    loc_output,
    loc_forcing,
    Val(loc_space_names),
    loc_obs,
    loc_land_init,
    args...)

@code_warntype updateModelParametersType(tblParams, forward, tblParams.defaults) # the main issue is the function itself