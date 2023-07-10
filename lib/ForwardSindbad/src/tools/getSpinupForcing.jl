export getSpinupForcing

@generated function getForcingForTimePeriod(forcing,
    ::Val{forc_vars},
    tstart::Int64,
    tend::Int64,
    f_t) where {forc_vars}
    output = quote end
    foreach(forc_vars) do forc
        push!(output.args, Expr(:(=), :v, Expr(:., :forcing, QuoteNode(forc))))
        push!(output.args, quote
            d = in(:time, AxisKeys.dimnames(v)) ? v[time=tstart:tend] : v
        end)
        return push!(output.args,
            Expr(:(=),
                :f_t,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., :f_t, QuoteNode(forc)), :d)))) #= none:1 =#
    end
    return output
end

function getForcingForTimePeriod(forcing, tstart::Int64, tend::Int64)
    map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=tstart:tend] : v
    end
end

#TODO: get all the getSpinupForcing methods to work correctly specially the ones with mean and recycleMSC
"""
getSpinupForcing(forcing, tem, ::Val{:full})
Set the spinup forcing as full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, f_one, ::Val{:full})
    return forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:recycleMSC})
Set the spinup forcing as the mean seasonal cycle of the full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, f_one, ::Val{:recycleMSC})
    spinup_forcing = getForcingForTimePeriod(forcing, Val(keys(forcing)), 1, 365, f_one)
    # spinup_forcing = forcing[1:365]
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:mean})
Set the spinup forcing as the mean of the full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, f_one, ::Val{:mean})
    spinup_forcing = mean(forcing)
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:yearOne})
Set the spinup forcing as the forcing of the first year from the full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, f_one, ::Val{:yearOne})
    spinup_forcing = getForcingForTimePeriod(forcing, Val(keys(forcing)), 1, 365, f_one)
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:yearRandom})
Set the spinup forcing as the forcing of a random full year from the full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, f_one, ::Val{:yearRandom})
    ## select a forcing for random year between start and end date
    # dates = tem.tem.helpers.dates.date_range
    # years = dates.Year
    # sel_year = random(dates.Year)
    # spinup_forcing = forcing(Date=sel_year)
    spinup_forcing = getForcingForTimePeriod(forcing, Val(keys(forcing)), 1, 365, f_one)
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem)
A function to prepare the spinup forcing. Returns a NamedTuple with subfields for different forcings needed in different spinup sequences. All spinup forcings are derived from the main input forcing using the other getSpinupForcing(forcing, tem, ::Val{:forcing_derivation_method}).
"""
function getSpinupForcing(forcing, tem_helpers, f_one)
    forcing_methods = Symbol[]
    for seq ∈ tem_helpers.spinup.sequence
        forc = seq["forcing"]
        if forc ∉ forcing_methods
            push!(forcing_methods, forc)
        end
    end
    spinup_forcing = (;)
    for forc ∈ forcing_methods
        spinup_forc = getSpinupForcing(forcing, tem, f_one, forc)
        spinup_forcing = setTupleField(spinup_forcing, (forc, spinup_forc))
    end
    return spinup_forcing
end

#TODO: get all the getSpinupForcing methods to work correctly specially the ones with mean and recycleMSC
"""
getSpinupForcing(forcing, tem, ::Val{:full})
Set the spinup forcing as full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, ::Val{:full})
    return forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:recycleMSC})
Set the spinup forcing as the mean seasonal cycle of the full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, ::Val{:recycleMSC})
    spinup_forcing = getForcingForTimePeriod(forcing, 1, 365)
    # spinup_forcing = forcing[1:365]
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:mean})
Set the spinup forcing as the mean of the full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, ::Val{:mean})
    spinup_forcing = mean(forcing)
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:yearOne})
Set the spinup forcing as the forcing of the first year from the full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, ::Val{:yearOne})
    spinup_forcing = getForcingForTimePeriod(forcing, 1, 365)
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:yearRandom})
Set the spinup forcing as the forcing of a random full year from the full input forcing.
"""
function getSpinupForcing(forcing, tem_helpers, ::Val{:yearRandom})
    ## select a forcing for random year between start and end date
    # dates = tem.tem.helpers.dates.date_range
    # years = dates.Year
    # sel_year = random(dates.Year)
    # spinup_forcing = forcing(Date=sel_year)
    spinup_forcing = getForcingForTimePeriod(forcing, 1, 365)
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem)
A function to prepare the spinup forcing. Returns a NamedTuple with subfields for different forcings needed in different spinup sequences. All spinup forcings are derived from the main input forcing using the other getSpinupForcing(forcing, tem, ::Val{:forcing_derivation_method}).
"""
function getSpinupForcing(forcing, tem)
    forcing_methods = []
    for seq ∈ tem.spinup.sequence
        forc = getfield(seq, :forcing)
        if forc ∉ forcing_methods
            push!(forcing_methods, forc)
        end
    end
    spinup_forcing = (;)
    for forc ∈ forcing_methods
        spinup_forc = getSpinupForcing(forcing, tem.helpers, forc)
        spinup_forcing = setTupleField(spinup_forcing, (val_to_symbol(forc), spinup_forc))
    end
    return spinup_forcing
end
