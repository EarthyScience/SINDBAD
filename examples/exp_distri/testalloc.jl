using BenchmarkTools
using Random
using Accessors
Random.seed!(12)
function processPackForcing(ex::Expr)
    rename, ex = if ex.args[1] == :(=)
        ex.args[2], ex.args[3]
    else
        nothing, ex
    end
    @assert ex.head == :call
    @assert ex.args[1] == :(=>)
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
        error("processPackLand: could not pack:" * lhs * "=" * rhs)
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
                        Expr(:(=), esc(s), esc(rn)))))
            expr_l
        elseif depth_field == 2
            top = Symbol(split(string(rhs), '.')[1])
            field = Symbol(split(string(rhs), '.')[2])
            #expr_l = Expr(:(=), esc(top), Expr(:tuple, Expr(:(...), esc(top)), Expr(:(=), esc(field), (Expr(:tuple, Expr(:parameters, Expr(:(...), esc(rhs)), Expr(:(=), esc(s), esc(rn))))))))
            Expr(:(=),
                esc(top),
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=),
                        Expr(:ref, Expr(:ref, esc(top), QuoteNode(field)), QuoteNode(s)),
                        esc(rn)))) #= none:1 =#
        end
    end
    return Expr(:block, lines...)
end

macro pack_land(outparams::Expr)
    @show typeof(outparams)
    @assert outparams.head == :block || outparams.head == :call || outparams.head == :(=)
    if outparams.head == :block
        #println("block")
        outputs = processPackLand.(filter(i -> isa(i, Expr), outparams.args))
        outCode = Expr(:block, outputs...)
    else
        #println("notblock")
        outCode = processPackLand(outparams)
    end
    return outCode
end
b = 12.0

macro test_it(forc)
    # @show forcing_nt_array, QuoteNode(forc)
    return Expr(Symbol("@set"),
        :(),
        Expr(:., :loc_forcing_t, forc),
        Expr(:if,
            Expr(:call, :in, :time, Expr(:call, Expr(:., :AxisKeys, :(:dimnames)), :v)),
            Expr(:ref, :v, :($(Expr(:kw, :time, ts)))),
            :v)) #= none:1 =#
end
ts = 5
@test_it :airT
function test_nt(out::NamedTuple, nt::Int64)
    for t ∈ 1:nt
        b = rand()#+out.fluxes.b
        @pack_land b => out
        # pack_nt(out)
    end
    return out
end

out_nt = (;)
out_nt = (; out_nt..., fluxes=(; b=rand()), pools=(; a=rand(100)))
@pack_land b => out_nt

out_new = test_nt(out_nt, 100);

#function pack_nt(out)
#    out_out = (; out..., fluxes=(; out.fluxes..., b=rand()))
#    return out_out
#end
#=
function test_dict(out, nt)
    for t = 1:nt
        pack_dict(out)
    end
end

function pack_dict(out)
    out[:fluxes][:b] = rand()
end
=#
out_nt = (;)
out_nt = (; out_nt..., fluxes=(;), pools=(; a=rand(100)))

@time for i ∈ 1:100
    test_nt(out_nt, 10)
end
@time test_nt(out_nt, 10);

@btime test_nt($out_nt, 100);
@code_warntype test_nt(out_nt, 10);

@btime a = out_nt.pools.a;
@btime a = getfield(getfield(out_nt, :pools), :a);
@btime a = out_nt[2][1];
using Flatten
using Accessors
out_nt = (;)
out_nt = (; out_nt..., fluxes=(; b=1.0), pools=(; a=rand(10)))
out_nt = (; out_nt..., fluxes=(;), pools=(; a=rand(100)))

function setacces(out_nt)
    return @set out_nt[:fluxes][:b] = rand()
end

@time a = setacces(out_nt);
@btime setacces($out_nt);

@pack_land b => out_nt.fluxes;

using Profile
Profile.clear_malloc_data() # clear allocations
@pack_land b => out_nt.fluxes;

b = 12.0

using NestedTuples
using BenchmarkTools
out_nt = (;)
out_nt = (; out_nt..., fluxes=(; b=1.0), pools=(; a=rand(10)))
Base.setindex(out_nt, Base.setindex(out_nt.fluxes, b, :b), :fluxes)
f = leaf_setter(out_nt)
@btime $f(2.3, rand(10))

@time out_nt = @set out_nt.fluxes.b = 2.0;

@btime $out_nt = @set $out_nt.fluxes.b = 2.0;

@btime $out_nt = @set $out_nt[:fluxes][:b] = 3.0

t = (a=1, b=2, fluxes=(;));
@btime @insert $t[:fluxes][:c] = rand()

#getproperty(getproperty(out_nt, :fluxes), :b)

# out_nt.
