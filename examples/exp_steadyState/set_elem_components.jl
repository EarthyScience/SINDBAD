export set_elem_components, set_pool_components
function set_pool_components(
    # @generated function set_pool_components(
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
                    :(helpers.numbers.𝟘),
                    :(helpers.numbers.𝟙),
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

function set_elem_components(
    land_init,
    helpers,
    ::Val{s_comps},
    ::Val{zix},
    p) where {s_comps,zix}
    output = quote end
    foreach(s_comps) do s_comp
        push!(output.args, Expr(:(=), :tmp, Expr(:., :(land_init.pools), QuoteNode(s_comp))))
        push!(output.args, Expr(:(=), :p_zix, Expr(:., :(helpers.pools.zix), QuoteNode(s_comp))))
        zix_pool = getfield(zix, s_comp)
        c_ix = 1
        foreach(zix_pool) do ix
            push!(output.args, Expr(:(=), :p_tmp, Expr(:call, :max, Expr(:ref, :p, ix), :(helpers.numbers.𝟘))))
            push!(output.args, Expr(:macrocall, Symbol("@rep_elem"), :(), Expr(:call, :(=>), :p_tmp, Expr(:tuple, :tmp, c_ix, QuoteNode(s_comp)))))
            #= none:1 =#
            c_ix += 1
        end
        push!(output.args,
            Expr(:(=),
                :land_init,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(), #= none:1 =#
                    Expr(:(=), Expr(:., :(land_init.pools), QuoteNode(s_comp)), :tmp)))) #= none:1 =#
    end
    return output
end