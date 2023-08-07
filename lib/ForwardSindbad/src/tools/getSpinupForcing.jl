export getSpinupForcing
export getForcingForTimePeriod

# @generated function getForcingForTimePeriod(
#     forcing,
#     f_t,
#     tperiod::Vector{Int64},
#     ::Val{forc_vars}) where {forc_vars}
#     output = quote end
#     foreach(forc_vars) do forc
#         push!(output.args, Expr(:(=), :v, Expr(:., :forcing, QuoteNode(forc))))
#         push!(output.args, quote
#             d = in(:time, AxisKeys.dimnames(v)) ? v[time=tperiod] : v
#         end)
#         return push!(output.args,
#             Expr(:(=),
#                 :f_t,
#                 Expr(:macrocall,
#                     Symbol("@set"),
#                     :(),
#                     Expr(:(=), Expr(:., :f_t, QuoteNode(forc)), :d)))) #= none:1 =#
#     end
#     return output
# end

# @generated function getTimeAggregatedForcing(
#     forcing,
#     f_t,
#     aggegator,
#     ::Val{forc_vars}) where {forc_vars}
#     output = quote end
#     foreach(forc_vars) do forc
#         push!(output.args, Expr(:(=), :v, Expr(:., :forcing, QuoteNode(forc))))
#         push!(output.args, quote
#             d = in(:time, AxisKeys.dimnames(v)) ? temporalAggregation(v, :aggregator, Val(:no_diff)) : v
#         end)
#         return push!(output.args,
#             Expr(:(=),
#                 :f_t,
#                 Expr(:macrocall,
#                     Symbol("@set"),
#                     :(),
#                     Expr(:(=), Expr(:., :f_t, QuoteNode(forc)), :d)))) #= none:1 =#
#     end
#     return output
# end


"""
    getTimeAggregatedForcing(forcing, time_aggregator)

DOCSTRING
"""
function getTimeAggregatedForcing(forcing, time_aggregator)
    sub_forcing = map(forcing) do v
        vtmp = v
        if in(:time, AxisKeys.dimnames(v))
            vtmp = v[time=1:length(time_aggregator[1].indices)]
            v = temporalAggregation(v, time_aggregator, Val(:no_diff))
            vtmp .= v
        end
        vtmp
    end
    return sub_forcing
end

"""
    getForcingForTimePeriod(forcing, tperiod::Vector{Int64})

DOCSTRING
"""
function getForcingForTimePeriod(forcing, tperiod::Vector{Int64})
    sub_forcing = map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=tperiod] : v
    end
    return sub_forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:full})
Set the spinup forcing as full input forcing.
"""
"""
    getSpinupForcing(forcing, forcing_one_timestep, time_aggregator, tem_helpers, nothing::Val{:no_diff})

DOCSTRING

# Arguments:
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `time_aggregator`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function getSpinupForcing(forcing, forcing_one_timestep, time_aggregator, tem_helpers, ::Val{:no_diff})
    return getTimeAggregatedForcing(forcing, time_aggregator)
end


"""
getSpinupForcing(forcing, tem, ::Val{:full})
Set the spinup forcing as full input forcing.
"""
"""
    getSpinupForcing(forcing, forcing_one_timestep, time_aggregator, tem_helpers, nothing::Val{:indexed})

DOCSTRING

# Arguments:
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `time_aggregator`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function getSpinupForcing(forcing, forcing_one_timestep, time_aggregator, tem_helpers, ::Val{:indexed})
    return getForcingForTimePeriod(forcing, time_aggregator)
end

"""
getSpinupForcing(forcing, tem)
A function to prepare the spinup forcing. Returns a NamedTuple with subfields for different forcings needed in different spinup sequences. All spinup forcings are derived from the main input forcing using the other getSpinupForcing(forcing, tem, ::Val{:forcing_derivation_method}).
"""
"""
    getSpinupForcing(forcing, forcing_one_timestep, spin_seq, tem_helpers)

DOCSTRING

# Arguments:
- `forcing`: DESCRIPTION
- `forcing_one_timestep`: DESCRIPTION
- `spin_seq`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
"""
function getSpinupForcing(forcing, forcing_one_timestep, spin_seq, tem_helpers)
    spinup_forcing = (;)
    for seq ∈ spin_seq
        forc = getfield(seq, :forcing)
        forc_name = valToSymbol(forc)
        if forc_name ∉ keys(spinup_forcing)
            spinup_forc = getSpinupForcing(forcing, forcing_one_timestep, seq.aggregator, tem_helpers, seq.aggregator_type)
            spinup_forcing = setTupleField(spinup_forcing, (valToSymbol(forc), spinup_forc))
        end
    end
    return spinup_forcing
end