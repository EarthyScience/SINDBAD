function test(st)::Vector{Float64}
    function objective(A, value)
        for i = 1:1_000_000
            A[i] = value[1]
        end

        return sum(A)
    end
    helper_objective = v -> objective(A, v)
    A = Vector{ForwardDiff.Dual{ForwardDiff.Tag{typeof(helper_objective),Float64},Float64,1}}(undef, 1_000_000)
    ForwardDiff.gradient(helper_objective, [st])
end



function test_gr(pv,
    mods,
    forc,
    op,
    obs,
    tblParams,
    tem_with_vals,
    info_optim,
    loc_space_inds,
    loc_forcings,
    loc_outputs,
    land_init_space,
    f_one)
    function objective(pv,
        mods,
        forc,
        op,
        obs,
        tblParams,
        tem_with_vals,
        info_optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)
        return g_loss(pv,
            mods,
            forc,
            op,
            obs,
            tblParams,
            tem_with_vals,
            info_optim,
            loc_space_inds,
            loc_forcings,
            loc_outputs,
            land_init_space,
            f_one)
    end
    helper_objective = v -> objective(v,
        mods,
        forc,
        op,
        obs,
        tblParams,
        tem_with_vals,
        info_optim,
        loc_space_inds,
        loc_forcings,
        loc_outputs,
        land_init_space,
        f_one)


    op_dat = [Vector{ForwardDiff.Dual{ForwardDiff.Tag{typeof(helper_objective),tem_with_vals.helpers.numbers.num_type},tem_with_vals.helpers.numbers.num_type,10}}(undef, length(od)) for od in op.data]
    op = (; op..., data=op_dat)
    ForwardDiff.gradient(helper_objective, pv)
end

