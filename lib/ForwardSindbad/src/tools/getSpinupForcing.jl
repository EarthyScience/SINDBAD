export getSpinupForcing
export getForcingForTimePeriod

# @generated function getForcingForTimePeriod(forcing,
#     ::Val{forc_vars},
#     tperiod::Vector{Int64},
#     f_t) where {forc_vars}
#         output = quote end
#         foreach(forc_vars) do forc
#             push!(output.args, Expr(:(=), :v, Expr(:., :forcing, QuoteNode(forc))))
#             push!(output.args, quote
#                 d = in(:time, AxisKeys.dimnames(v)) ? v[time=tperiod] : v
#             end)
#             return push!(output.args,
#                 Expr(:(=),
#                     :f_t,
#                     Expr(:macrocall,
#                         Symbol("@set"),
#                         :(),
#                         Expr(:(=), Expr(:., :f_t, QuoteNode(forc)), :d)))) #= none:1 =#
#         end
#         return output
# end

# @generated function getTimeAggregatedForcing(forcing,
#     ::Val{forc_vars},
#     aggegator,
#     f_t) where {forc_vars}
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
function getSpinupForcing(forcing, tem_helpers, f_one, time_aggregator, ::Val{:no_diff})
    return getTimeAggregatedForcing(forcing, time_aggregator)
end


"""
getSpinupForcing(forcing, tem, ::Val{:full})
Set the spinup forcing as full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, f_one, time_aggregator, ::Val{:indexed})
    return getForcingForTimePeriod(forcing, time_aggregator)
    # return getForcingForTimePeriod(forcing, tem_helpers.vals.forc_vars, time_aggregator, f_one)
end

"""
getSpinupForcing(forcing, tem, ::Val{:random_year})
Set the spinup forcing as the forcing of a random full year from the full input forcing.
"""
function getSpinupForcing(forcing, _, tem_helpers, f_one, spin_seq)
    return getSpinupForcing(forcing, tem_helpers, f_one, spin_seq.aggregator, spin_seq.aggregator_type)
end

"""
getSpinupForcing(forcing, tem)
A function to prepare the spinup forcing. Returns a NamedTuple with subfields for different forcings needed in different spinup sequences. All spinup forcings are derived from the main input forcing using the other getSpinupForcing(forcing, tem, ::Val{:forcing_derivation_method}).
"""
function getSpinupForcing(forcing, tem_spinup, tem_helpers, f_one)
    spinup_forcing = (;)
    for seq ∈ tem_spinup.sequence
        forc = getfield(seq, :forcing)
        forc_name = valToSymbol(forc)
        if forc_name ∉ keys(spinup_forcing)
            # @show forc_name
            spinup_forc = getSpinupForcing(forcing, tem_spinup, tem_helpers, f_one, seq)
            # @time spinup_forc = getSpinupForcing(forcing, tem.helpers, f_one, seq)
            spinup_forcing = setTupleField(spinup_forcing, (valToSymbol(forc), spinup_forc))
        end
    end
    return spinup_forcing
end