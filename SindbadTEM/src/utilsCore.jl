export addToElem, @add_to_elem, addToEachElem, addVec
export clampZeroOne
export cumSum!
export flagUpper, flagLower
export getFrac
export getMethodTypes
export getSindbadModelOrder
export getSindbadModels
export getZix
export isInvalid
export maxZero, maxOne, minZero, minOne
export offDiag, offDiagUpper, offDiagLower
export @pack_nt, @unpack_nt
export repElem, @rep_elem, repVec, @rep_vec
export setComponents
export setComponentFromMainPool, setMainFromComponentPool
export showInfo
export showInfoSeparator
export totalS


"""
    @add_to_elem

macro to add to an element of a vector or a static vector.    
    
# Example
```julia
helpers = (; pools =(;
        zeros=(; cOther = 0.0f0,),
        ones = (; cOther = 1.0f0 ))
        )
cOther = [100.0f0, 1.0f0]
# and then add 1.0f0 to the first element of cOther
@add_to_elem 1 ⇒ (cOther, 1, :cOther)
```    
"""
macro add_to_elem(outparams::Expr)
    @assert outparams.head == :call || outparams.head == :(=)
    @assert outparams.args[1] == :(⇒)
    @assert length(outparams.args) == 3
    lhs = esc(outparams.args[2])
    rhs = outparams.args[3]
    rhsa = rhs.args
    tar = esc(rhsa[1])
    indx = rhsa[2]
    hp_pool = rhsa[3]
    outCode = [
        Expr(:(=),
            tar,
            Expr(:call,
                addToElem,
                tar,
                lhs,
                esc(Expr(:., :(helpers.pools.zeros), hp_pool)),
                # esc(:(land.constants.z_zero)),
                esc(indx)))
    ]
    return Expr(:block, outCode...)
end

"""
    addToElem(v::SVector, Δv, v_zero, ind::Int)
    addToElem(v::AbstractVector, Δv, _, ind::Int)

# Arguments
- `v`: a StaticVector or AbstractVector
- `Δv`: the value to be added
- `v_zero`: a StaticVector of zeros
- `ind::Int`: the index of the element to be added

"""
function addToElem end

function addToElem(v::SVector, Δv, v_zero, ind::Int)
    n_0 = zero(first(v_zero))
    n_1 = one(first(v_zero))
    v_zero = v_zero .* n_0
    v_zero = Base.setindex(v_zero, n_1, ind)
    v = v .+ v_zero .* Δv
    return v
end

function addToElem(v::AbstractVector, Δv, _, ind::Int)
    v[ind] = v[ind] + Δv
    return v
end

"""
    addToEachElem(v::SVector, Δv:Real)
    addToEachElem(v::AbstractVector, Δv:Real)

add Δv to each element of v when v is a StaticVector or a Vector.

# Arguments
- `v`: a StaticVector or AbstractVector
- `Δv`: the value to be added to each element
"""
function addToEachElem end

function addToEachElem(v::SVector, Δv::Real)
    v = v .+ Δv
    return v
end

function addToEachElem(v::AbstractVector, Δv::Real)
    v .= v .+ Δv
    return v
end

"""
    addVec(v::SVector, Δv::SVector)
    addVec(v::AbstractVector, Δv::AbstractVector)

add Δv to v when v is a StaticVector or a Vector.

# Arguments
- `v`: a StaticVector or AbstractVector
- `Δv`: a StaticVector or AbstractVector
"""
function addVec end

function addVec(v::SVector, Δv::SVector)
    v = v + Δv
    return v
end

function addVec(v::AbstractVector, Δv::AbstractVector)
    v .= v .+ Δv
    return v
end


"""
    clampZeroOne(num)

returns max(min(num, 1), 0)
"""
function clampZeroOne(num)
    return clamp(num, zero(num), one(num))
end

"""
    cumSum!(i_n::AbstractVector, o_ut::AbstractVector)

fill out the output vector with the cumulative sum of elements from input vector
"""
function cumSum!(i_n::AbstractVector, o_ut::AbstractVector)
    for i ∈ eachindex(i_n)
        o_ut[i] = sum(i_n[1:i])
    end
    return o_ut
end


"""
    flagOffDiag(A::AbstractMatrix)

returns a matrix of same shape as input with 1 for all non diagonal elements
"""
function flagOffDiag(A::AbstractMatrix)
    o_mat = zeros(size(A))
    for ι ∈ CartesianIndices(A)
        if ι[1] ≠ ι[2]
            o_mat[ι] = 1
        end
    end
    return o_mat
end


"""
    flagLower(A::AbstractMatrix)

returns a matrix of same shape as input with 1 for all below diagonal elements and 0 elsewhere
"""
function flagLower(A::AbstractMatrix)
    o_mat = zeros(size(A))
    for ι ∈ CartesianIndices(A)
        if ι[1] > ι[2]
            o_mat[ι] = 1
        end
    end
    return o_mat
end

"""
    flagUpper(A::AbstractMatrix)

returns a matrix of same shape as input with 1 for all above diagonal elements and 0 elsewhere
"""
function flagUpper(A::AbstractMatrix)
    o_mat = zeros(size(A))
    for ι ∈ CartesianIndices(A)
        if ι[1] < ι[2]
            o_mat[ι] = 1
        end
    end
    return o_mat
end



"""
    getFrac(num, den)

return either a ratio or numerator depending on whether denomitor is a zero
"""
function getFrac(num, den)
    if !iszero(den)
        rat = num / den
    else
        rat = num
    end
    return rat
end


"""
    getMethodTypes(fn)

Retrieve the types of the arguments for all methods of a given function.

# Arguments
- `fn`: The function for which the method argument types are to be retrieved.

# Returns
- A vector containing the types of the arguments for each method of the function.

# Example
```julia
function example_function(x::Int, y::String) end
function example_function(x::Float64, y::Bool) end

types = getMethodTypes(example_function)
println(types) # Output: [Int64, Float64]
```
"""
function getMethodTypes(fn)
    # Get the method table for the function
    mt = methods(fn)
    # Extract the types of the first method
    method_types = map(m -> m.sig.parameters[2], mt)
    return method_types
end

"""
    getSindbadModelOrder(model_name)

helper function to return the default order of a sindbad model
"""
function getSindbadModelOrder(model_name; all_models=standard_sindbad_models)
    mo = findall(x -> x == model_name, all_models)[1]
    println("The order [default] of $(model_name) in models.jl of core SINDBAD is $(mo)")
end

"""
    getSindbadModels()

helper function to return a dictionary of sindbad model and approaches
"""
function getSindbadModels(; all_models=standard_sindbad_models)
    approaches = []
    for _md ∈ all_models
        push!(approaches, Pair(_md, [nameof(_x) for _x in subtypes(getfield(SindbadTEM.Models, _md))]))
    end
    return DataStructures.OrderedDict(approaches)
end

"""
    getZix(dat::SubArray)
    getZix(dat::SubArray, zixhelpersPool)
    getZix(dat::Array, zixhelpersPool)
    getZix(dat::SVector, zixhelpersPool)

returns the indices of a view for a subArray

"""
function getZix end

function getZix(dat::SubArray)
    return Tuple(first(parentindices(dat)))
end

function getZix(dat::SubArray, zixhelpersPool)
    return Tuple(first(parentindices(dat)))
end

function getZix(dat::Array, zixhelpersPool)
    return zixhelpersPool
end

function getZix(dat::SVector, zixhelpersPool)
    return zixhelpersPool
end


"""
    maxZero(num)

returns max(num, 0)
"""
function maxZero(num)
    return max(num, zero(num))
end


"""
    maxOne(num)

returns max(num, 1)
"""
function maxOne(num)
    return max(num, one(num))
end


"""
    minZero(num)

returns min(num, 0)
"""
function minZero(num)
    return min(num, zero(num))
end


"""
    minOne(num)

returns min(num, 1)
"""
function minOne(num)
    return min(num, one(num))
end


"""
    offDiag(A::AbstractMatrix)

returns a vector comprising of off diagonal elements of a matrix
"""
function offDiag(A::AbstractMatrix)
    @view A[[ι for ι ∈ CartesianIndices(A) if ι[1] ≠ ι[2]]]
end

"""
    offDiagLower(A::AbstractMatrix)

returns a vector comprising of below diagonal elements of a matrix
"""
function offDiagLower(A::AbstractMatrix)
    @view A[[ι for ι ∈ CartesianIndices(A) if ι[1] > ι[2]]]
end

"""
    offDiagUpper(A::AbstractMatrix)

returns a vector comprising of above diagonal elements of a matrix
"""
function offDiagUpper(A::AbstractMatrix)
    @view A[[ι for ι ∈ CartesianIndices(A) if ι[1] < ι[2]]]
end

"""
    @pack_nt

macro to pack variables into a named tuple.

# Example
```julia
@pack_nt begin
    (a, b) ⇒ land.diagnostics
    (c, d, f) ⇒ land.fluxes
end
# or 
@pack_nt (a, b) ⇒ land.diagnostics
# or 
@pack_nt a ⇒ land.diagnostics
```
"""
macro pack_nt(outparams)
    @assert outparams.head == :block || outparams.head == :call || outparams.head == :(=)
    if outparams.head == :block
        outputs = processPackNT.(filter(i -> isa(i, Expr), outparams.args))
        outCode = Expr(:block, outputs...)
    else
        outCode = processPackNT(outparams)
    end
    return outCode
end

"""
    processPackNT(ex)


"""
function processPackNT(ex)
    rename, ex = if ex.head == :(=)
        ex.args[1], ex.args[2]
    else
        nothing, ex
    end
    @assert ex.head == :call
    @assert ex.args[1] == :(⇒)
    @assert length(ex.args) == 3
    lhs = ex.args[2]
    rhs = ex.args[3]
    if lhs isa Symbol
        #println("symbol")
        lhs = [lhs]
    elseif lhs.head == :tuple
        #println("tuple")
        lhs = lhs.args
    else
        error("processPackNT: could not pack:" * lhs * "=" * rhs)
    end
    if rename === nothing
        rename = lhs
    elseif rename isa Expr && rename.head == :tuple
        rename = rename.args
    end
    lines = broadcast(lhs, rename) do s, rn
        depth_field = length(findall(".", string(esc(rhs)))) + 1
        if depth_field == 1
            expr_l = Expr(:(=),
                esc(rhs),
                Expr(:tuple,
                    Expr(:parameters, Expr(:(...), esc(rhs)),
                        Expr(:kw, esc(s), esc(rn)))))
            # expr_l = Expr(:(=), esc(rhs), Expr(:tuple, Expr(:parameters, Expr(:(...), esc(rhs)), Expr(:(=), esc(s), esc(rn)))))
            expr_l
        elseif depth_field == 2
            top = Symbol(split(string(rhs), '.')[1])
            field = Symbol(split(string(rhs), '.')[2])
            tmp = Expr(:(=),
                esc(top),
                Expr(:tuple,
                    Expr(:(...), esc(top)),
                    Expr(:(=),
                        esc(field),
                        (Expr(:tuple,
                            Expr(:parameters, Expr(:(...), esc(rhs)),
                                Expr(:kw, esc(s), esc(rn))))))))
            # tmp = Expr(:(=), esc(top), Expr(:macrocall, Symbol("@set"), :(#= none:1 =#), Expr(:(=), Expr(:ref, Expr(:ref, esc(top), QuoteNode(field)), QuoteNode(s)), esc(rn))))
            tmp
        end
    end
    return Expr(:block, lines...)
end

"""
    processUnpackNT(ex)


"""
function processUnpackNT(ex)
    rename, ex = if ex.head == :(=)
        ex.args[1], ex.args[2]
    else
        nothing, ex
    end
    @assert ex.head == :call
    @assert ex.args[1] == :(⇐)
    @assert length(ex.args) == 3
    lhs = ex.args[2]
    rhs = ex.args[3]
    if lhs isa Symbol
        lhs = [lhs]
    elseif lhs.head == :tuple
        lhs = lhs.args
    else
        error("processUnpackNT: could not unpack:" * lhs * "=" * rhs)
    end
    if rename === nothing
        rename = lhs
    elseif rename isa Expr && rename.head == :tuple
        rename = rename.args
    end
    lines = broadcast(lhs, rename) do s, rn
        return Expr(:(=), esc(rn), Expr(:(.), esc(rhs), QuoteNode(s)))
    end
    return Expr(:block, lines...)
end

"""
    @rep_elem
macro to replace an element of a vector or a static vector.

# Example
```julia
helpers = (; pools =(;
        zeros=(; cOther = 0.0f0,),
        ones = (; cOther = 1.0f0 ))
        )
cOther = [100.0f0, 1.0f0]
# and then replace the first element of cOther with 1.0f0
@rep_elem 1 ⇒ (cOther, 1, :cOther) 
```
"""
macro rep_elem(outparams::Expr)
    @assert outparams.head == :call || outparams.head == :(=)
    @assert outparams.args[1] == :(⇒)
    @assert length(outparams.args) == 3
    lhs = esc(outparams.args[2])
    rhs = outparams.args[3]
    rhsa = rhs.args
    tar = esc(rhsa[1])
    indx = rhsa[2]
    hp_pool = rhsa[3]
    outCode = [
        Expr(:(=),
            tar,
            Expr(:call,
                repElem,
                tar,
                lhs,
                esc(Expr(:., :(helpers.pools.zeros), hp_pool)),
                esc(Expr(:., :(helpers.pools.ones), hp_pool)),
                esc(indx)))
    ]
    return Expr(:block, outCode...)
end

"""
    repElem(v::AbstractVector, v_elem, _, _, ind::Int)
    repElem(v::SVector, v_elem, v_zero, v_one, ind::Int)

# Arguments
- `v`: a StaticVector or AbstractVector
- `v_elem`: the value to be replaced with
- `v_zero`: a StaticVector of zeros
- `v_one`: a StaticVector of ones
- `ind::Int`: the index of the element to be replaced
"""
function repElem end

function repElem(v::AbstractVector, v_elem, _, _, ind::Int)
    v[ind] = v_elem
    return v
end

function repElem(v::SVector, v_elem, v_zero, v_one, ind::Int)
    n_0 = zero(first(v_zero))
    n_1 = one(first(v_zero))
    v_zero = v_zero .* n_0
    v_zero = Base.setindex(v_zero, n_1, ind)
    v_one = v_one .* n_0 .+ n_1
    v_one = Base.setindex(v_one, n_0, ind)
    v = v .* v_one .+ v_zero .* v_elem
    # v = Base.setindex(v, v_elem, vlit_level)
    return v
end

"""
    @rep_vec
macro to replace a vector or a static vector with a new value.

# Example
```julia
_vec = [100.0f0, 2.0f0]
# and then replace the vector with 1.0f0
@rep_vec _vec ⇒ 1.0f0
# or with a new vector
@rep_vec _vec ⇒ [3.0f0, 2.0f0]

```
"""
macro rep_vec(outparams::Expr)
    @assert outparams.head == :call || outparams.head == :(=)
    @assert outparams.args[1] == :(⇒)
    @assert length(outparams.args) == 3
    lhs = esc(outparams.args[2])
    rhs = esc(outparams.args[3])
    outCode = [Expr(:(=), lhs, Expr(:call, repVec, lhs, rhs))]
    return Expr(:block, outCode...)
end

"""
    repVec(v::AbstractVector, v_new)
    repVec(v::SVector, v_new)

replaces the values of a vector with a new value

# Arguments:
- `v`: an AbstractVector or a StaticVector
- `v_new`: a new value to replace the old one

"""
function repVec end

function repVec(v::AbstractVector, v_new)
    v .= v_new
    return v
end

function repVec(v::SVector, v_new)
    n_0 = zero(first(v))
    v = v .* n_0 + v_new
    return v
end

"""
    setComponents(land, helpers, Val{s_main}, Val{s_comps}, Val{zix})

# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: helper NT with necessary objects for model run and type consistencies
- `::Val{s_main}`: a NT with names of the main pools
- `::Val{s_comps}`: a NT with names of the component pools
- `::Val{zix}`: a NT with zix of each pool
"""
function setComponents(
    land,
    helpers,
    ::Val{s_main},
    ::Val{s_comps},
    ::Val{zix}) where {s_main,s_comps,zix}
    output = quote end
    push!(output.args, Expr(:(=), s_main, Expr(:., :(land.pools), QuoteNode(s_main))))
    foreach(s_comps) do s_comp
        push!(output.args, Expr(:(=), s_comp, Expr(:., :(land.pools), QuoteNode(s_comp))))
        zix_pool = getfield(zix, s_comp)
        c_ix = 1
        foreach(zix_pool) do ix
            push!(output.args, Expr(:(=),
                s_comp,
                Expr(:call,
                    rep_elem,
                    s_comp,
                    Expr(:ref, s_main, ix),
                    Expr(:., :(helpers.pools.zeros), QuoteNode(s_comp)),
                    Expr(:., :(helpers.pools.ones), QuoteNode(s_comp)),
                    :(land.constants.z_zero),
                    :(land.constants.o_one),
                    c_ix)))

            c_ix += 1
        end
        push!(output.args, Expr(:(=),
            :land,
            Expr(:tuple,
                Expr(:(...), :land),
                Expr(:(=),
                    :pools,
                    (Expr(:tuple,
                        Expr(:parameters, Expr(:(...), :(land.pools)),
                            Expr(:kw, s_comp, s_comp))))))))
    end
    return output
end


"""
    setComponentFromMainPool(land, helpers, Val{s_main}, Val{s_comps}, Val{zix})

- sets the component pools value using the values for the main pool
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json


# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: helper NT with necessary objects for model run and type consistencies
- `::Val{s_main}`: a NT with names of the main pools
- `::Val{s_comps}`: a NT with names of the component pools
- `::Val{zix}`: a NT with zix of each pool
"""
@generated function setComponentFromMainPool(
    # function setComponentFromMainPool(
    land,
    helpers,
    ::Val{s_main},
    ::Val{s_comps},
    ::Val{zix}) where {s_main,s_comps,zix}
    gen_output = quote end
    push!(gen_output.args, Expr(:(=), s_main, Expr(:., :(land.pools), QuoteNode(s_main))))
    foreach(s_comps) do s_comp
        push!(gen_output.args, Expr(:(=), s_comp, Expr(:., :(land.pools), QuoteNode(s_comp))))
        zix_pool = getfield(zix, s_comp)
        c_ix = 1
        foreach(zix_pool) do ix
            push!(gen_output.args, Expr(:(=),
                s_comp,
                Expr(:call,
                    rep_elem,
                    s_comp,
                    Expr(:ref, s_main, ix),
                    Expr(:., :(helpers.pools.zeros), QuoteNode(s_comp)),
                    Expr(:., :(helpers.pools.ones), QuoteNode(s_comp)),
                    :(land.constants.z_zero),
                    :(land.constants.o_one),
                    c_ix)))

            c_ix += 1
        end
        push!(gen_output.args, Expr(:(=),
            :land,
            Expr(:tuple,
                Expr(:(...), :land),
                Expr(:(=),
                    :pools,
                    (Expr(:tuple,
                        Expr(:parameters, Expr(:(...), :(land.pools)),
                            Expr(:kw, s_comp, s_comp))))))))
    end
    return gen_output
end


"""
    setMainFromComponentPool(land, helpers, Val{s_main}, Val{s_comps}, Val{zix})

- sets the main pool from the values of the component pools
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json

# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: helper NT with necessary objects for model run and type consistencies
- `::Val{s_main}`: a NT with names of the main pools
- `::Val{s_comps}`: a NT with names of the component pools
- `::Val{zix}`: a NT with zix of each pool
"""
@generated function setMainFromComponentPool(
    land,
    helpers,
    ::Val{s_main},
    ::Val{s_comps},
    ::Val{zix}) where {s_main,s_comps,zix}
    gen_output = quote end
    push!(gen_output.args, Expr(:(=), s_main, Expr(:., :(land.pools), QuoteNode(s_main))))
    foreach(s_comps) do s_comp
        push!(gen_output.args, Expr(:(=), s_comp, Expr(:., :(land.pools), QuoteNode(s_comp))))
        zix_pool = getfield(zix, s_comp)
        c_ix = 1
        foreach(zix_pool) do ix
            push!(gen_output.args, Expr(:(=),
                s_main,
                Expr(:call,
                    rep_elem,
                    s_main,
                    Expr(:ref, s_comp, c_ix),
                    Expr(:., :(helpers.pools.zeros), QuoteNode(s_main)),
                    Expr(:., :(helpers.pools.ones), QuoteNode(s_main)),
                    :(land.constants.z_zero),
                    :(land.constants.o_one),
                    ix)))
            c_ix += 1
        end
    end
    push!(gen_output.args, Expr(:(=),
        :land,
        Expr(:tuple,
            Expr(:(...), :land),
            Expr(:(=),
                :pools,
                (Expr(:tuple,
                    Expr(:parameters, Expr(:(...), :(land.pools)),
                        Expr(:kw, s_main, s_main))))))))
    return gen_output
end


"""
    showInfo(func, file_name, line_number, info_message; spacer=" ", n_f=1, n_m=1)

Logs an informational message with optional function, file, and line number context.

# Arguments
- `func`: The function object or `nothing` if not applicable.
- `file_name`: The name of the file where the message originates.
- `line_number`: The line number in the file.
- `info_message`: The message to log.
- `spacer`: (Optional) String used for spacing in the log output (default: `" "`).
- `n_f`: (Optional) Number of times to repeat `spacer` before the function/file info (default: `1`).
- `n_m`: (Optional) Number of times to repeat `spacer` before the message (default: `1`).

# Example
```julia
showInfo(myfunc, "myfile.jl", 42, "Computation finished")
```
"""
function showInfo(func, file_name, line_number, info_message; spacer=" ", n_f= 1, n_m=1, display_color=(0, 152, 221))
    func_space = spacer ^ n_f
    info_space = spacer ^ n_m
    file_link = ""
    mpi_color = (17, 102, 86)  # Default color for info messages
    if !isnothing(func)
        file_link = " $(nameof(func)) (`$(first(splitext(basename(file_name))))`.jl:$(line_number)) => "
        # display_color = (79, 255, 55)
        # display_color = :red
        display_color = (74, 192, 60)
    end
    show_str = "$(func_space)$(file_link)$(info_space)$(info_message)"

    println(showInfoColored(show_str, display_color))
    # @info show_str
end


"""
    showInfoColored(s::String, color)

Returns a string with segments enclosed in backticks (`) colored using the specified RGB color.

# Arguments
- `s::String`: The input string. Segments to be colored should be enclosed in backticks (e.g., `"This is `colored` text"`).
- `color`: An RGB tuple (e.g., `(0, 152, 221)`) specifying the foreground color to use.

# Returns
- A string with the specified segments colored, suitable for display in terminals that support ANSI color codes.

# Example
```julia
println(showInfoColored("This is `colored` text", (0, 152, 221)))
```
This will print "This is colored text" with "colored" in the specified color.

# Notes
- Only the segments between backticks are colored; other text remains uncolored.
- The function uses Crayons.jl for coloring, so output is best viewed in compatible terminals.
"""
function showInfoColored(s::String, color)
    # Create a Crayon object with the specified color
    crayon = Crayon(foreground = color)

    # Split the string by backticks
    parts = split(s, "`")

    # Initialize an empty string for the output
    output = ""

    # Iterate through the parts and color the segments
    for (i, part) in enumerate(parts)
        if i % 2 == 0  # Even indices are segments to color
            output *= string(crayon(part))  # Convert CrayonWrapper to string
        else
            output *= part  # Odd indices are regular text
        end
    end

    return output
end

"""
    showInfoSeparator(; sep_text="", sep_width=100, display_color=(223,184,21))

Prints a visually distinct separator line to the console, optionally with centered text.

# Arguments
- `sep_text`: (Optional) A string to display centered within the separator. If empty, a line of dashes is printed. Default is `""`.
- `sep_width`: (Optional) The total width of the separator line. Default is `100`.
- `display_color`: (Optional) An RGB tuple specifying the color of the separator line. Default is `(223,184,21)`.

# Example
```julia
showInfoSeparator()
showInfoSeparator(sep_text=" SECTION START ", sep_width=80)
```

# Notes
- The separator line is colored for emphasis.
- Useful for visually dividing output sections in logs or the console.
"""
function showInfoSeparator(; sep_text="", sep_width=100, display_color=(223,184,21))
    if isempty(sep_text) 
        sep_text=repeat("-", sep_width)
    else
        sep_remain = (sep_width - length(sep_text))%2
        sep_text = repeat("-", div(sep_width - length(sep_text) + sep_remain, 2)) * sep_text * repeat("-", div(sep_width - length(sep_text) + sep_remain, 2))
    end
    showInfo(nothing, @__FILE__, @__LINE__, "\n`$(sep_text)`\n", display_color=display_color, n_f=0, n_m=0)
end    
"""
    totalS(s, sΔ)

return total storage amount given the storage and the current delta storage without creating an allocation for a temporary array
"""
function totalS(s, sΔ)
    sm = zero(eltype(s))
    for si ∈ eachindex(s)
        sm = sm + s[si] + sΔ[si]
    end
    return sm
end

"""
    totalS(s)

return total storage amount given the storage without creating an allocation for a temporary array
"""
function totalS(s)
    sm = zero(eltype(s))
    for si ∈ eachindex(s)
        sm = sm + s[si]
    end
    return sm
end


"""
    @unpack_nt

macro to unpack variables from a named tuple.

# Example

```julia
@unpack_nt (f1, f2) ⇐ forcing # named tuple
@unpack_nt var1 ⇐ land.diagnostics # named tuple
# or 
@unpack_nt begin
    (f1, f2) ⇐ forcing
    var1 ⇐ land.diagnostics
end
```
"""
macro unpack_nt(inparams)
    @assert inparams.head == :block || inparams.head == :call || inparams.head == :(=)
    if inparams.head == :block
        outputs = processUnpackNT.(filter(i -> isa(i, Expr), inparams.args))
        outCode = Expr(:block, outputs...)
    else
        outCode = processUnpackNT(inparams)
    end
    return outCode
end


"""
    isInvalid(_data::Number)

Checks if a number is invalid (e.g., `nothing`, `missing`, `NaN`, or `Inf`).

# Arguments:
- `_data`: The input number.

# Returns:
`true` if the number is invalid, otherwise `false`.
"""
function isInvalid(_data)
    return isnothing(_data) || ismissing(_data) || isnan(_data) || isinf(_data)
end
