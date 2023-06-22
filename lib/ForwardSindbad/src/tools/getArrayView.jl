
export getArrayView

# function getArrayView(a::AbstractArray{Float32,2}, inds::AbstractArray)
#     # @show inds, length(inds), typeof(inds)
#         view(a, :, inds...)
#     # return view(a, inds...)
# end

# function getArrayView(a::AbstractArray{Float32,3}, inds::AbstractArray)
#     # @show inds, length(inds), typeof(inds)
#     if length(inds) == 1
#         view(a, :, :, inds...)
#     else
#         view(a, :, inds...)
#     end
# end

# function getArrayView(a::AbstractArray{Float32,4}, inds::AbstractArray)
#     # @show size(a), inds, typeof(inds)
#     if length(inds) == 1
#         view(a, :, :, :, inds...)
#     else
#         view(a, :, :, inds...)
#     end
# end

# function getArrayView(a::AbstractArray{Float32,2}, inds::Tuple{Int64})
#     # @show 2, 1, inds, length(inds), typeof(inds)
#     view(a, :, first(inds))
# end

# function getArrayView(a::AbstractArray{Float32,2}, inds::Tuple{Int64, Int64})
#     # @show 2, 2, inds, length(inds), typeof(inds)
#     view(a, first(inds), last(inds))
# end

# function getArrayView(a::AbstractArray{Float32,4}, inds::Tuple{Int64})
#     # @show 4, 1, inds, length(inds), typeof(inds)
#     view(a, :, :, :, first(inds))
# end

# function getArrayView(a::AbstractArray{Float32,4}, inds::Tuple{Int64, Int64})
#     # @show 4, 2, inds, length(inds), typeof(inds)
#     view(a, :, :, first(inds), last(inds))
# end

# function getArrayView(a::AbstractArray{Float32,3}, inds::Tuple{Int64})
#     # @show 3, 1, inds, length(inds), typeof(inds)
#     view(a, :, :, first(inds))
# end

# function getArrayView(a::AbstractArray{Float32,3}, inds::Tuple{Int64, Int64})
#     # @show 3, 2, inds, length(inds), typeof(inds)
#     view(a, :, first(inds), last(inds))
# end

# function getArrayView(a::AbstractArray{Float64,2}, inds::AbstractArray)
#     # @show inds, length(inds), typeof(inds)
#         view(a, :, inds...)
#     # return view(a, inds...)
# end

# function getArrayView(a::AbstractArray{Float64,3}, inds::AbstractArray)
#     # @show inds, length(inds), typeof(inds)
#     if length(inds) == 1
#         view(a, :, :, inds...)
#     else
#         view(a, :, inds...)
#     end
# end

# function getArrayView(a::AbstractArray{Float64,4}, inds::AbstractArray)
#     # @show size(a), inds, typeof(inds)
#     if length(inds) == 1
#         view(a, :, :, :, inds...)
#     else
#         view(a, :, :, inds...)
#     end
# end

# function getArrayView(a::AbstractArray{Float64,2}, inds::Tuple{Int64})
#     # @show 2, 1, inds, length(inds), typeof(inds)
#     view(a, :, first(inds))
# end

# function getArrayView(a::AbstractArray{Float64,2}, inds::Tuple{Int64, Int64})
#     # @show 2, 2, inds, length(inds), typeof(inds)
#     view(a, first(inds), last(inds))
# end

# function getArrayView(a::AbstractArray{Float64,4}, inds::Tuple{Int64})
#     # @show 4, 1, inds, length(inds), typeof(inds)
#     view(a, :, :, :, first(inds))
# end

# function getArrayView(a::AbstractArray{Float64,4}, inds::Tuple{Int64, Int64})
#     # @show 4, 2, inds, length(inds), typeof(inds)
#     view(a, :, :, first(inds), last(inds))
# end

# function getArrayView(a::AbstractArray{Float64,3}, inds::Tuple{Int64})
#     # @show 3, 1, inds, length(inds), typeof(inds)
#     view(a, :, :, first(inds))
# end

# function getArrayView(a::AbstractArray{Float64,3}, inds::Tuple{Int64, Int64})
#     # @show 3, 2, inds, length(inds), typeof(inds)
#     view(a, :, first(inds), last(inds))
# end

function getArrayView(a::AbstractArray{<:Real,2}, inds::AbstractArray)
    # @show inds, length(inds), typeof(inds)
    return view(a, :, inds...)
    # return view(a, inds...)
end

function getArrayView(a::AbstractArray{<:Real,3}, inds::AbstractArray)
    # @show inds, length(inds), typeof(inds)
    if length(inds) == 1
        view(a, :, :, inds...)
    else
        view(a, :, inds...)
    end
end

function getArrayView(a::AbstractArray{<:Real,4}, inds::AbstractArray)
    # @show size(a), inds, typeof(inds)
    if length(inds) == 1
        view(a, :, :, :, inds...)
    else
        view(a, :, :, inds...)
    end
end

function getArrayView(a::AbstractArray{<:Real,2}, inds::Tuple{Int64})
    # @show 2, 1, inds, length(inds), typeof(inds)
    return view(a, :, first(inds))
end

function getArrayView(a::AbstractArray{<:Real,2}, inds::Tuple{Int64,Int64})
    # @show 2, 2, inds, length(inds), typeof(inds)
    return view(a, first(inds), last(inds))
end

function getArrayView(a::AbstractArray{<:Real,4}, inds::Tuple{Int64})
    # @show 4, 1, inds, length(inds), typeof(inds)
    return view(a, :, :, :, first(inds))
end

function getArrayView(a::AbstractArray{<:Real,4}, inds::Tuple{Int64,Int64})
    # @show 4, 2, inds, length(inds), typeof(inds)
    return view(a, :, :, first(inds), last(inds))
end

function getArrayView(a::AbstractArray{<:Real,3}, inds::Tuple{Int64})
    # @show 3, 1, inds, length(inds), typeof(inds)
    return view(a, :, :, first(inds))
end

function getArrayView(a::AbstractArray{<:Real,3}, inds::Tuple{Int64,Int64})
    # @show 3, 2, inds, length(inds), typeof(inds)
    return view(a, :, first(inds), last(inds))
end
