function setParam(p::AbstractParam, newVal) # updateStateVariable
    # chech is units are the same and update if possible.
    return @set p.val = newVal
end