export getSpinupForcing

function getForcingForTimePeriod(forcing, tstart, tend)
    map(forcing) do v
        in(:time, AxisKeys.dimnames(v)) ? v[time=tstart:tend] : v
    end
end

#TODO: get all the getSpinupForcing methods to work correctly specially the ones with mean and recycleMSC
"""
getSpinupForcing(forcing, tem, ::Val{:full})
Set the spinup forcing as full input forcing.
"""
function getSpinupForcing(forcing, tem, ::Val{:full})
    return forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:recycleMSC})
Set the spinup forcing as the mean seasonal cycle of the full input forcing.
"""
function getSpinupForcing(forcing, tem, ::Val{:recycleMSC})
    spinup_forcing = getForcingForTimePeriod(forcing, 1, 365)
    # spinup_forcing = forcing[1:365]
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:mean})
Set the spinup forcing as the mean of the full input forcing.
"""
function getSpinupForcing(forcing, tem, ::Val{:mean})
    spinup_forcing = mean(forcing)
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:yearOne})
Set the spinup forcing as the forcing of the first year from the full input forcing.
"""
function getSpinupForcing(forcing, tem, ::Val{:yearOne})
    spinup_forcing = getForcingForTimePeriod(forcing, 1, 365)
    return spinup_forcing
end

"""
getSpinupForcing(forcing, tem, ::Val{:yearRandom})
Set the spinup forcing as the forcing of a random full year from the full input forcing.
"""
function getSpinupForcing(forcing, tem, ::Val{:yearRandom})
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
    for seq in tem.spinup.sequence
        forc = Symbol(seq["forcing"])
        if forc ∉ forcing_methods
            push!(forcing_methods, forc)
        end
    end
    spinup_forcing = (;)
    for forc in forcing_methods
        spinup_forc = getSpinupForcing(forcing, tem, Val(forc))
        spinup_forcing = setTupleField(spinup_forcing, (forc, spinup_forc))
    end
    return spinup_forcing
end