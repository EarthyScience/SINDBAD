export getForcingForTimeStep
export getLocData
export setOutputForTimeStep!

"""
    fillLocOutput!(ar::T, val::T1, ts::T2) where {T, T1, T2<:Int}

Fill an array `ar` with value `val` at specific time step `ts`. Generic function that works with
different array and value types, where the time step must be an integer.

# Arguments
- `ar::T`: Target array to be filled
- `val::T1`: Value to fill into the array
- `ts::T2<:Int`: Time step indicating position to fill

# Notes
- Modifies the input array `ar` in-place
- Time step `ts` must be an integer type

# Returns
Nothing, modifies input array in-place
"""
function fillLocOutput!(ar::T, val::T1, ts::T2) where {T, T1, T2<:Int}
    data_ts = getLocArrayView(ar, val, ts)
    return data_ts .= val
end


"""
    getForcingForTimeStep(forcing, loc_forcing_t, ts, Val{forc_with_type})

Get forcing values for a specific time step based on the forcing type.

# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_forcing_t`: a forcing NT for a single timestep to be reused in every time step
- `ts`: time step to get the forcing for
- `forc_with_type`: Value type parameter specifying the forcing type
"""
function getForcingForTimeStep(forcing, loc_forcing_t, ts, ::Val{forc_with_type}) where {forc_with_type}
    if @generated
        gen_output = quote end
        foreach(forc_with_type) do forc_pair
            forc = first(forc_pair)
            forc_type=last(forc_pair)
            push!(gen_output.args, Expr(:(=), :d, Expr(:call, :getForcingV, Expr(:., :forcing, QuoteNode(forc)), :ts, forc_type)))
            push!(gen_output.args,
                Expr(:(=),
                    :loc_forcing_t,
                    Expr(:macrocall,
                        Symbol("@set"),
                        :(),
                        Expr(:(=), Expr(:., :loc_forcing_t, QuoteNode(forc)), :d)))) #= none:1 =#
        end
        return gen_output
    else
        map(forc_with_type) do forc_pair
            forc = first(forc_pair)
            forc_type=last(forc_pair)
            getForcingV(forcing[forc], ts, forc_type)
        end
    end
end

"""
    getForcingV(v, ts, <: ForcingTime)

Retrieves forcing values for a specific time step or returns constant forcing values, depending on the forcing type.

# Arguments:
- `v`: The input forcing data. Can be time-dependent or constant.
- `ts`: The time step (integer) for which the forcing value is retrieved. Ignored for constant forcing types.
- `<: ForcingTime`: The type of forcing, which determines how the value is retrieved:
    - `ForcingWithTime`: Retrieves the forcing value for the specified time step `ts`.
    - `ForcingWithoutTime`: Returns the constant forcing value, ignoring `ts`.

# Returns:
- The forcing value for the specified time step (if time-dependent) or the constant forcing value.

# Extended Help
# Examples:
1. **Time-dependent forcing**:
```julia
forcing = [1.0, 2.0, 3.0]  # Forcing values for time steps
ts = 2                     # Time step
value = getForcingV(forcing, ts, ForcingWithTime())
# value = 2.0
```

2. **Constant forcing**:
```julia
forcing = 5.0              # Constant forcing value
ts = 3                     # Time step (ignored)
value = getForcingV(forcing, ts, ForcingWithoutTime())
# value = 5.0
```
"""
getForcingV

function getForcingV(v, ts, ::ForcingWithTime)
    v[ts]
end

function getForcingV(v, _, ::ForcingWithoutTime)
    v
end

"""
    getLocData(forcing, output_array, loc_ind)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output_array`: an output array/view for ALL locations
- `loc_ind`: a tuple with the spatial indices of the data for a given location
"""
function getLocData(forcing::NamedTuple, output_array::AbstractArray, loc_ind)
    loc_forcing = getLocData(forcing, loc_ind)
    loc_output = getLocData(output_array, loc_ind)
    return loc_forcing, loc_output
end


"""
    getLocData(forcing, output_array, loc_ind)



# Arguments:
- `output_array`: an output array/view for ALL locations
- `loc_ind`: a tuple with the spatial indices of the data for a given location
"""
function getLocData(output_array::AbstractArray, loc_ind)
    loc_output = map(output_array) do a
        getArrayView(a, loc_ind)
    end
    return loc_output
end


"""
    getLocData(forcing, output_array, loc_ind)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `loc_ind`: a tuple with the spatial indices of the data for a given location
"""
function getLocData(forcing::NamedTuple, loc_ind)
    loc_forcing = map(forcing) do a
        getArrayView(a, loc_ind) |> Array
    end
    return loc_forcing
end


"""
    getLocArrayView(ar, val, ts)

Creates a view of the input array `ar` for a specific time step `ts`, based on the type of `val`.

# Arguments:
- `ar`: The input array from which a view is created.
- `val`: The value or vector used to determine the size or structure of the view.
    - If `val` is an `AbstractVector`, the view spans the time step `ts` and the size of `val`.
    - If `val` is a `Real` value, the view spans only the time step `ts`.
- `ts`: The time step (integer) for which the view is created.

# Returns:
- A view of the array `ar` corresponding to the specified time step `ts`.

# Notes:
- The function dynamically adjusts the view based on whether `val` is a vector or a scalar.
- This is useful for efficiently accessing or modifying specific slices of the array without copying data.

# Examples:
1. **Creating a view with a vector `val`**:
```julia
ar = rand(10, 5)  # A 10x5 array
val = rand(5)     # A vector of size 5
ts = 3            # Time step
view_ar = getLocArrayView(ar, val, ts)
```

2. **Creating a view with a scalar `val`**:
```julia
ar = rand(10)     # A 1D array
val = 42.0        # A scalar value
ts = 2            # Time step
view_ar = getLocArrayView(ar, val, ts)
```
"""
getLocArrayView

function getLocArrayView(ar::T, val::T1, ts::T2) where {T, T1<:AbstractVector, T2<:Int}
    return view(ar, ts, 1:size(val,1))
end

function getLocArrayView(ar::T, val::T1, ts::T2) where {T, T1<:Real, T2<:Int}
    return view(ar, ts)
end


"""
    setOutputForTimeStep!(outputs, land, ts, Val{output_vars})



# Arguments:
- `outputs`: vector of model output vectors
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `ts`: time step
- `::Val{output_vars}`: a dispatch for vals of the output variables to generate the function
"""
function setOutputForTimeStep!(outputs, land, ts, ::Val{output_vars}) where {output_vars}
    if @generated
        gen_output = quote end
        for (i, ov) in enumerate(output_vars)
            field = first(ov)
            subfield = last(ov)
            push!(gen_output.args,
                Expr(:(=), :data_l, Expr(:., Expr(:., :land, QuoteNode(field)), QuoteNode(subfield))))
            push!(gen_output.args, quote
                data_o = outputs[$i]
                fillLocOutput!(data_o, data_l, ts)
            end)
        end
        return gen_output
    else
        for (i, ov) in enumerate(output_vars)
            field = first(ov)
            subfield = last(ov)
            data_l = getfield(getfield(land, field), subfield)
            # @show i, ov, size(data_l)
            data_o = outputs[i]
            fillLocOutput!(data_o, data_l, ts)
        end
        return nothing
    end
end
