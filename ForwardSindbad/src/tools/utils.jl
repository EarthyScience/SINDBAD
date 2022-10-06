export AllNaN
export nanmax, nanmin
export landWrapper

"""
    AllNaN <: YAXArrays.DAT.ProcFilter
Add skipping filter for pixels with all nans in YAXArrays 
"""
struct AllNaN <: YAXArrays.DAT.ProcFilter end
YAXArrays.DAT.checkskip(::AllNaN, x) = all(isnan, x)

"""
    nanmax(dat) = maximum(dat[.!isnan.(dat)])
Calculate the maximum of an array while skipping nan
"""
nanmax(dat) = maximum(filter(!isnan,dat))

"""
    nanmax(dat) = minimum(dat[.!isnan.(dat)])
Calculate the minimum of an array while skipping nan
"""
nanmin(dat) = minimum(filter(!isnan,dat))

"""
    landWrapper{S}
Wrap the nested fields of namedtuple output of sindbad land into a nested structure of views that can be easily accessed with a dot notation
"""
struct landWrapper{S}
    s::S
end
struct GroupView{S}
    groupname::Symbol
    s::S
end
struct ArrayView{T,N,S<:AbstractArray{<:Any,N}} <: AbstractArray{T,N}
    s::S
    groupname::Symbol
    arrayname::Symbol
end
Base.getproperty(s::landWrapper,f::Symbol) = GroupView(f,getfield(s,:s))
function Base.getproperty(g::GroupView,f::Symbol)
    allarrays = getfield(g,:s)
    groupname = getfield(g,:groupname)
    T = typeof(first(allarrays)[groupname][f])
    ArrayView{T,ndims(allarrays),typeof(allarrays)}(allarrays,groupname,f)
end
Base.size(a::ArrayView) = size(a.s)
Base.IndexStyle(a::Type{<:ArrayView}) = IndexLinear()
Base.getindex(a::ArrayView,i::Int) = a.s[i][a.groupname][a.arrayname]
Base.propertynames(o::landWrapper) = propertynames(first(getfield(o,:s)))
Base.keys(o::landWrapper) = propertynames(o)
Base.getindex(o::landWrapper,s::Symbol) = getproperty(o,s)
Base.propertynames(o::GroupView) = propertynames(first(getfield(o,:s))[getfield(o,:groupname)])
Base.keys(o::GroupView) = propertynames(o)
Base.getindex(o::GroupView,i::Symbol) = getproperty(o,i)