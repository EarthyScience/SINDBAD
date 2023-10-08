
export getArrayView

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


# """
# function getArrayView(a::AbstractArray{<:Real,1}, inds::Tuple{Int64})
#     # @show 2, 1, inds, length(inds), typeof(inds)
#     return view(a, first(inds))
# end

# """
#     getArrayView(a::AbstractArray{<:Real, 2}, inds::Tuple{Int64})


# """
# function getArrayView(a::AbstractArray{<:Real,2}, inds::Tuple{Int64})
#     # @show 2, 1, inds, length(inds), typeof(inds)
#     return view(a, :, first(inds))
# end

# """
#     getArrayView(a::AbstractArray{<:Real, 3}, inds::Tuple{Int64})


# """
# function getArrayView(a::AbstractArray{<:Real,3}, inds::Tuple{Int64})
#     # @show 3, 1, inds, length(inds), typeof(inds)
#     return view(a, :, :, first(inds))
# end

# """
#     getArrayView(a::AbstractArray{<:Real, 4}, inds::Tuple{Int64})


# """
# function getArrayView(a::AbstractArray{<:Real,4}, inds::Tuple{Int64})
#     # @show 4, 1, inds, length(inds), typeof(inds)
#     return view(a, :, :, :, first(inds))
# end


# """
#     getArrayView(a::AbstractArray{<:Real, 2}, inds::Tuple{Int64, Int64})


# """
# function getArrayView(a::AbstractArray{<:Real,2}, inds::Tuple{Int64,Int64})
#     # @show 2, 2, inds, length(inds), typeof(inds)
#     return view(a, first(inds), last(inds))
# end

# """
#     getArrayView(a::AbstractArray{<:Real, 3}, inds::Tuple{Int64, Int64})


# """
# function getArrayView(a::AbstractArray{<:Real,3}, inds::Tuple{Int64,Int64})
#     # @show 3, 2, inds, length(inds), typeof(inds)
#     return view(a, :, first(inds), last(inds))
# end

# """
#     getArrayView(a::AbstractArray{<:Real, 4}, inds::Tuple{Int64, Int64})


# """
# function getArrayView(a::AbstractArray{<:Real,4}, inds::Tuple{Int64,Int64})
#     # @show 4, 2, inds, length(inds), typeof(inds)
#     return view(a, :, :, first(inds), last(inds))
# end