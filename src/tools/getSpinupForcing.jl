export getSpinupForcing
function getSpinupForcing(forcing, info, ::Val{:full})
    return forcing
end

function getSpinupForcing(forcing, info, ::Val{:recycleMSC})
    spinup_forcing = forcing[1:365]
    return spinup_forcing
end

function getSpinupForcing(forcing, info, ::Val{:mean})
    spinup_forcing = mean(forcing)
    return spinup_forcing
end

function getSpinupForcing(forcing, info, ::Val{:yearOne})
    spinup_forcing = forcing[1:365]
    return spinup_forcing
end

function getSpinupForcing(forcing, info, ::Val{:yearRandom})
    ## select a forcing for random year between start and end date
    # dates = info.tem.helpers.dates.date_range
    # years = dates.Year
    # sel_year = random(dates.Year)
    # spinup_forcing = forcing(Date=sel_year)
    spinup_forcing = forcing[1:365]
    return spinup_forcing
end

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
        spinup_forc = getSpinupForcing(forcing, info, Val(forc))
        spinup_forcing = setTupleField(spinup_forcing, (forc, spinup_forc))
    end
    return spinup_forcing
end