export getLocData
export getLocForcing!
export getLocOutput!
export setOutputForTimeStep!

function fillLocOutput!(ar, val, ts::Int64)
    data_ts = getLocOutputView(ar, val, ts)
    return data_ts .= val
end

function getLocData(output_array, forcing, loc_space_map)
    loc_forcing = map(forcing) do a
        view(a; loc_space_map...)
    end
    # ar_inds = last.(loc_space_map)
    ar_inds = Tuple(last.(loc_space_map))

    loc_output = map(output_array) do a
        getArrayView(a, ar_inds)
    end
    return loc_forcing, loc_output
end

@generated function getLocForcing!(forcing,
    ::Val{forc_vars},
    ::Val{s_names},
    loc_forcing,
    s_locs) where {forc_vars,s_names}
    output = quote end
    foreach(forc_vars) do forc
        push!(output.args, Expr(:(=), :d, Expr(:., :forcing, QuoteNode(forc))))
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
            s_ind += 1
        end
        push!(output.args,
            Expr(:(=),
                :loc_forcing,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., :loc_forcing, QuoteNode(forc)), :d)))) #= none:1 =#
    end
    return output
end

function getLocOutput!(output_array, ar_inds, loc_output)
    for i ∈ eachindex(output_array)
        loc_output[i] = getArrayView(output_array[i], ar_inds)
    end
    return nothing
end

function getLocOutputView(ar, val::AbstractVector, ts::Int64)
    return view(ar, ts, 1:length(val))
end

function getLocOutputView(ar, val::Real, ts::Int64)
    return view(ar, ts)
end

function setOutputForTimeStep!(outputs, land, ::Val{output_vars}, ts) where {output_vars}
    if @generated
        output = quote end
        for (i, ov) in enumerate(output_vars)
            field = first(ov)
            subfield = last(ov)
            push!(output.args,
                Expr(:(=), :data_l, Expr(:., Expr(:., :land, QuoteNode(field)), QuoteNode(subfield))))
            push!(output.args, quote
                data_o = outputs[$i]
                fillLocOutput!(data_o, data_l, ts)
            end)
        end
        return output
    else
        for (i, ov) in enumerate(output_vars)
            field = first(ov)
            subfield = last(ov)
            data_l = getfield(getfield(land, field), subfield)
            data_o = outputs[i]
            fillLocOutput!(data_o, data_l, ts)
        end
    end
end


function viewCopyYax(xout, xin)
    if ndims(xout) == ndims(xin)
        for i ∈ eachindex(xin)
            xout[i] = xin[i][1]
        end
    else
        for i ∈ CartesianIndices(xin)
            xout[:, i] .= xin[i]
        end
    end
end