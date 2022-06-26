export getSpinupForcing

#TODO: get all the setSpinupForcing methods to work correctly specially the ones with mean and recycleMSC
"""
setSpinupForcing(forcing, info, ::Val{:yearOne})
Set the spinup forcing as full input forcing.
"""
function setSpinupForcing(forcing, info, ::Val{:full})
    return forcing
end

"""
setSpinupForcing(forcing, info, ::Val{:recycleMSC})
Set the spinup forcing as the mean seasonal cycle of the full input forcing.
"""
function setSpinupForcing(forcing, info, ::Val{:recycleMSC})
    spinup_forcing = forcing[1:365]
    return spinup_forcing
end

"""
setSpinupForcing(forcing, info, ::Val{:yearOne})
Set the spinup forcing as the mean of the full input forcing.
"""
function setSpinupForcing(forcing, info, ::Val{:mean})
    spinup_forcing = mean(forcing)
    return spinup_forcing
end

"""
setSpinupForcing(forcing, info, ::Val{:yearOne})
Set the spinup forcing as the forcing of the first year from the full input forcing.
"""
function setSpinupForcing(forcing, info, ::Val{:yearOne})
    spinup_forcing = forcing[1:365]
    return spinup_forcing
end

"""
setSpinupForcing(forcing, info, ::Val{:yearRandom})
Set the spinup forcing as the forcing of a random full year from the full input forcing.
"""
function setSpinupForcing(forcing, info, ::Val{:yearRandom})
    ## select a forcing for random year between start and end date
    # dates = info.tem.helpers.dates.date_range
    # years = dates.Year
    # sel_year = random(dates.Year)
    # spinup_forcing = forcing(Date=sel_year)
    spinup_forcing = forcing[1:365]
    return spinup_forcing
end

"""
getSpinupForcing(forcing, info)
A function to prepare the spinup forcing. Returns a NamedTuple with subfields for different forcings needed in different spinup sequences. All spinup forcings are derived from the main input forcing using the other setSpinupForcing(forcing, info, ::Val{:forcing_derivation_method}).
"""
function getSpinupForcing(forcing, info)
    forcing_methods = []
    for seq in info.spinup.sequence
        forc = Symbol(seq["forcing"])
        if forc ∉ forcing_methods
            push!(forcing_methods, forc)
        end
    end
    spinup_forcing = (;)
    for forc in forcing_methods
        spinup_forc = setSpinupForcing(forcing, info, Val(forc))
        spinup_forcing = setTupleField(spinup_forcing, (forc, spinup_forc))
    end
    return spinup_forcing
end