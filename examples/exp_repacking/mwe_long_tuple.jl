struct LongTuple{T <: Tuple}
    data::T
    function LongTuple(arg::T) where {T<: Tuple}
        return new{T}(arg)
    end
    function LongTuple(args...)
        n = 6
        s = length(args)
        nt = s ÷ n
        r = mod(s,n) # 5 for our current use case
        nt = r == 0 ? nt : nt + 1
        idx = 1
        tup = ntuple(nt) do i
            n = r != 0 && i==nt ? r : n
            t = ntuple(x -> args[x+idx-1], n)
            idx += n
            return t
        end
        return new{typeof(tup)}(tup)
    end
end

Base.map(f, arg::LongTuple) = LongTuple(map(tup-> map(f, tup), arg.data))

@inline Base.foreach(f, arg::LongTuple) = foreach(tup-> foreach(f, tup), arg.data)

@generated function reduce_lt(f, x::LongTuple{<: Tuple{Vararg{Any,N}}}; init) where {N}
    exes = []
    for i in 1:N
        N2 = i==N ? 5 : 6
        for j in 1:N2
            push!(exes, :(init = f(x.data[$i][$j], init)))
        end
    end
    return Expr(:block, exes...)
end

