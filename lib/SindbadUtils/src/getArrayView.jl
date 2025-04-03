
export getArrayView
export stackArrays

"""
    getArrayView(_dat::AbstractArray{<:Any, N}, inds::Tuple{Vararg{Int}}) where N

Creates a view of the input array `_dat` based on the provided indices tuple `inds`.

# Arguments:
- `_dat`: The input array from which a view is created. Can be of any dimensionality.
- `inds`: A tuple of integer indices specifying the spatial or temporal dimensions to slice.

# Returns:
- A `SubArray` view of `_dat` corresponding to the specified indices.

# Notes:
- The function supports arrays of arbitrary dimensions (`N`).
- For arrays with fewer dimensions than the size of `inds`, an error is thrown.
- For higher-dimensional arrays, the indices are applied to the last dimensions, while earlier dimensions are accessed using `Colon()` (i.e., all elements are included).
- This function avoids copying data by creating a view, which is efficient for large arrays.

# Error Handling:
- Throws an error if the dimensionality of `_dat` is less than the size of `inds`.
"""
getArrayView

function getArrayView(_dat::AbstractArray{<:Any,N}, inds::Tuple{Int}) where N
    if N == 1
        view(_dat, first(inds))
    else
        dim = 1 
        d_size = size(_dat)
        view_inds = map(d_size) do _
            vi = dim == length(d_size) ? first(inds) : Colon()
            dim += 1 
            vi
        end
        view(_dat, view_inds...)
    end
end

function getArrayView(_dat::AbstractArray{<:Any,N}, inds::Tuple{Int,Int}) where N
    if N == 1
        error("cannot get a view of 1-dimensional array in space using spatial indices tuple of size 2")
    elseif N == 2
        view(_dat, first(inds), last(inds))
    else
        dim = 1 
        d_size = size(_dat)
        view_inds = map(d_size) do _
            vi = dim == length(d_size) ? last(inds) : dim == length(d_size) - 1 ? first(inds) : Colon()
            dim += 1 
            vi
        end
        view(_dat, view_inds...)
    end
end


function getArrayView(_dat::AbstractArray{<:Any,N}, inds::Tuple{Int,Int,Int}) where N
    if N < 3
        error("cannot get a view of smaller than 3-dimensional array in space using spatial indices tuple of size 3")
    elseif N == 3
        view(_dat, first(inds), inds[2], last(inds))
    else
        dim = 1 
        d_size = size(_dat)
        view_inds = map(d_size) do _
            vi = dim == length(d_size) ? last(inds) : dim == length(d_size) - 1 ? inds[2] : dim == length(d_size) - 2 ? first(inds) : Colon()
            dim += 1 
            vi
        end
        view(_dat, view_inds...)
    end
end


function getArrayView(_dat::AbstractArray{<:Any,N}, inds::Tuple{Int,Int,Int,Int}) where N
    if N < 4
        error("cannot get a view of smaller than 4-dimensional array in space using spatial indices tuple of size 4")
    elseif N == 4
        view(_dat, first(inds), inds[2], inds[3], last(inds))
    else
        dim = 1 
        d_size = size(_dat)
        view_inds = map(d_size) do _
            vi = dim == length(d_size) ? last(inds) : dim == length(d_size) - 1 ? inds[3] : dim == length(d_size) - 2 ? inds[2] : dim == length(d_size) - 3 ? first(inds) : Colon()
            dim += 1 
            vi
        end
        view(_dat, view_inds...)
    end
end

"""
    stackArrays(arr)

Stacks a collection of arrays along the first dimension.

# Arguments:
- `arr`: A collection of arrays to be stacked. All arrays must have the same size along their non-stacked dimensions.

# Returns:
- A single array where the input arrays are stacked along the first dimension.
- If the arrays are 1D, the result is a vector.

# Notes:
- The function uses `hcat` to horizontally concatenate the arrays and then creates a view to stack them along the first dimension.
- If the first dimension of the input arrays has a size of 1, the result is flattened into a vector.
- This function is efficient and avoids unnecessary data copying.
"""
function stackArrays(arr)
    result = view(reduce(hcat, arr), :, :)
    return length(arr[1]) == 1 ? vec(result) : result
end