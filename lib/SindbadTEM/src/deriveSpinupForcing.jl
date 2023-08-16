export getSpinupForcing

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
#             d = in(:time, AxisKeys.dimnames(v)) ? temporalAggregation(v, :aggregator, ::TimeNoDiff) : v
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
    getSpinupForcing(forcing, forcing_one_timestep, time_aggregator, tem_helpers, ::TimeNoDiff)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `time_aggregator`: time aggregator instances to do the temporal aggregation of forcing data
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::TimeNoDiff`: a type dispatch to use the temporal aggregator of SindbadUtils
"""
function getSpinupForcing(forcing, forcing_one_timestep, time_aggregator, tem_helpers, ::TimeNoDiff)
    sub_forcing = map(forcing) do v
        vtmp = v
        if in(:time, AxisKeys.dimnames(v))
            vtmp = v[time=1:length(time_aggregator[1].indices)]
            v = temporalAggregation(v, time_aggregator, TimeNoDiff())
            vtmp .= v
        end
        vtmp
    end
    return sub_forcing
end

"""
    getSpinupForcing(forcing, forcing_one_timestep, time_aggregator, tem_helpers, ::TimeIndexed)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `time_aggregator`: time aggregator instances to do the temporal aggregation of forcing data
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::TimeIndexed`: a type dispatch to just slice the time series using index
"""
function getSpinupForcing(forcing, forcing_one_timestep, time_aggregator, tem_helpers, ::TimeIndexed)
    sub_forcing = map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=time_aggregator] : v
    end
    return sub_forcing
end


"""
    getSpinupForcing(forcing, forcing_one_timestep, spin_seq, tem_helpers)

A function to prepare the spinup forcing. Returns a NamedTuple with subfields for different forcings needed in different spinup sequences. All spinup forcings are derived from the main input forcing using the other getSpinupForcing(forcing, tem, ::ForcingDerivationMethod})

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `forcing_one_timestep`: a forcing NT for a single location and a single time step
- `spin_seq`: a sequence of information to carry out spinup at different steps with information on models to use, forcing, stopping critera, etc.
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function getSpinupForcing(forcing, forcing_one_timestep, spin_seq, tem_helpers)
    spinup_forcing = (;)
    for seq ∈ spin_seq
        forc = getfield(seq, :forcing)
        forc_name = forc
        if forc_name ∉ keys(spinup_forcing)
            spinup_forc = getSpinupForcing(forcing, forcing_one_timestep, seq.aggregator, tem_helpers, seq.aggregator_type)
            spinup_forcing = setTupleField(spinup_forcing, (forc_name, spinup_forc))
        end
    end
    return spinup_forcing
end