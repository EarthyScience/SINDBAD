
export getArrayView

"""
    getArrayView(a::AbstractArray{<:Real, 2}, inds::Tuple{Int64})


"""
function getArrayView(a::AbstractArray{<:Real,1}, inds::Tuple{Int64})
    # @show 2, 1, inds, length(inds), typeof(inds)
    return view(a, first(inds))
end

"""
    getArrayView(a::AbstractArray{<:Real, 2}, inds::Tuple{Int64})


"""
function getArrayView(a::AbstractArray{<:Real,2}, inds::Tuple{Int64})
    # @show 2, 1, inds, length(inds), typeof(inds)
    return view(a, :, first(inds))
end

"""
    getArrayView(a::AbstractArray{<:Real, 3}, inds::Tuple{Int64})


"""
function getArrayView(a::AbstractArray{<:Real,3}, inds::Tuple{Int64})
    # @show 3, 1, inds, length(inds), typeof(inds)
    return view(a, :, :, first(inds))
end

"""
    getArrayView(a::AbstractArray{<:Real, 4}, inds::Tuple{Int64})


"""
function getArrayView(a::AbstractArray{<:Real,4}, inds::Tuple{Int64})
    # @show 4, 1, inds, length(inds), typeof(inds)
    return view(a, :, :, :, first(inds))
end


"""
    getArrayView(a::AbstractArray{<:Real, 2}, inds::Tuple{Int64, Int64})


"""
function getArrayView(a::AbstractArray{<:Real,2}, inds::Tuple{Int64,Int64})
    # @show 2, 2, inds, length(inds), typeof(inds)
    return view(a, first(inds), last(inds))
end

"""
    getArrayView(a::AbstractArray{<:Real, 3}, inds::Tuple{Int64, Int64})


"""
function getArrayView(a::AbstractArray{<:Real,3}, inds::Tuple{Int64,Int64})
    # @show 3, 2, inds, length(inds), typeof(inds)
    return view(a, :, first(inds), last(inds))
end

"""
    getArrayView(a::AbstractArray{<:Real, 4}, inds::Tuple{Int64, Int64})


"""
function getArrayView(a::AbstractArray{<:Real,4}, inds::Tuple{Int64,Int64})
    # @show 4, 2, inds, length(inds), typeof(inds)
    return view(a, :, :, first(inds), last(inds))
end