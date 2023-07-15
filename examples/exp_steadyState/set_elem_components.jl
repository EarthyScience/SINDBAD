export set_component_from_main_pool, set_main_from_component_pool

"""
    set_component_from_main_pool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)
- sets the component pools value using the values for the main pool
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json
"""
@generated function set_component_from_main_pool(
    # function set_component_from_main_pool(
    land,
    helpers,
    ::Val{s_main},
    ::Val{s_comps},
    ::Val{zix}) where {s_main,s_comps,zix}
    output = quote end
    push!(output.args, Expr(:(=), s_main, Expr(:., :(land.pools), QuoteNode(s_main))))
    foreach(s_comps) do s_comp
        push!(output.args, Expr(:(=), s_comp, Expr(:., :(land.pools), QuoteNode(s_comp))))
        zix_pool = getfield(zix, s_comp)
        c_ix = 1
        foreach(zix_pool) do ix
            push!(output.args, Expr(:(=),
                s_comp,
                Expr(:call,
                    rep_elem,
                    s_comp,
                    Expr(:ref, s_main, ix),
                    Expr(:., :(helpers.pools.zeros), QuoteNode(s_comp)),
                    Expr(:., :(helpers.pools.ones), QuoteNode(s_comp)),
                    :(land.wCycleBase.z_zero),
                    :(land.wCycleBase.o_one),
                    c_ix)))

            c_ix += 1
        end
        push!(output.args, Expr(:(=),
            :land,
            Expr(:tuple,
                Expr(:(...), :land),
                Expr(:(=),
                    :pools,
                    (Expr(:tuple,
                        Expr(:parameters, Expr(:(...), :(land.pools)),
                            Expr(:kw, s_comp, s_comp))))))))
    end
    return output
end


"""
    set_main_from_component_pool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)
- sets the main pool from the values of the component pools
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json
"""

@generated function set_main_from_component_pool(
    # function set_main_from_component_pool(
    land,
    helpers,
    ::Val{s_main},
    ::Val{s_comps},
    ::Val{zix}) where {s_main,s_comps,zix}
    output = quote end
    push!(output.args, Expr(:(=), s_main, Expr(:., :(land.pools), QuoteNode(s_main))))
    foreach(s_comps) do s_comp
        push!(output.args, Expr(:(=), s_comp, Expr(:., :(land.pools), QuoteNode(s_comp))))
        zix_pool = getfield(zix, s_comp)
        c_ix = 1
        foreach(zix_pool) do ix
            push!(output.args, Expr(:(=),
                s_main,
                Expr(:call,
                    rep_elem,
                    s_main,
                    Expr(:ref, s_comp, c_ix),
                    Expr(:., :(helpers.pools.zeros), QuoteNode(s_comp)),
                    Expr(:., :(helpers.pools.ones), QuoteNode(s_comp)),
                    :(land.wCycleBase.z_zero),
                    :(land.wCycleBase.o_one),
                    ix)))
            c_ix += 1
        end
    end
    push!(output.args, Expr(:(=),
        :land,
        Expr(:tuple,
            Expr(:(...), :land),
            Expr(:(=),
                :pools,
                (Expr(:tuple,
                    Expr(:parameters, Expr(:(...), :(land.pools)),
                        Expr(:kw, s_main, s_main))))))))
    return output
end