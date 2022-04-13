aM = [
	"cVegLeaf"; "cLitLeafM"; "out.states.p_cTaufpVeg_MTF"; 
	"cVegLeaf"; "cLitLeafS"; "1 - out.states.p_cTaufpVeg_MTF"; 
	"cVegWood"; "cLitWood"; 1; 
	"cVegRootF"; "cLitRootFM"; "out.states.p_cTaufpVeg_MTF"; 
	"cVegRootF"; "cLitRootFS"; "1 - out.states.p_cTaufpVeg_MTF"; 
	"cVegRootC"; "cLitRootC"; 1; 
	"cLitLeafS"; "cSoilSlow"; "out.states.p_cTaufpVeg_SCLIGNIN"; 
	"cLitLeafS"; "cMicSurf"; "1 - out.states.p_cTaufpVeg_SCLIGNIN"; 
	"cLitRootFS"; "cSoilSlow"; "out.states.p_cTaufpVeg_SCLIGNIN"; 
	"cLitRootFS"; "cMicSoil"; "1 - out.states.p_cTaufpVeg_SCLIGNIN"; 
	"cLitWood"; "cSoilSlow"; "WOODLIGFRAC"; 
	"cLitWood"; "cMicSurf"; "1 - WOODLIGFRAC"; 
	"cLitRootC"; "cSoilSlow"; "WOODLIGFRAC"; 
	"cLitRootC"; "cMicSoil"; "1 - WOODLIGFRAC"; 
	"cSoilOld"; "cMicSoil"; 1; 
	"cLitLeafM"; "cMicSurf"; 1; 
	"cLitRootFM"; "cMicSoil"; 1; 
	"cMicSurf"; "cSoilSlow"; 1; 
];
    



function processPackingLine(ex)
    rename, ex = if ex.args[1] == :(=>)
        ex.args[2], ex.args[3]
    else
        nothing, ex
    end
    @assert ex.head == :call
    @assert ex.args[1] == :(∋)
    @assert length(ex.args) == 3
    lhs = ex.args[2]
    rhs = ex.args[3]
    if lhs isa Symbol
        lhs = [lhs]
    elseif lhs.head == :tuple
        lhs = lhs.args
    else
        error("processinputline: could not pack:" * lhs * "=>" * rhs)
    end
    if rename === nothing
        rename = lhs
    elseif rename isa Expr && rename.head==:tuple
        rename = rename.args
    end
    lines = broadcast(lhs,rename) do s,rn
        depth_field = length(findall(".", string(esc(rhs)))) + 1
        if depth_field == 1
            expr_l = Expr(:(=),esc(rhs), Expr(:tuple, Expr(:parameters, Expr(:(...),esc(rhs)), Expr(:(=), esc(s), esc(rn)))))
            expr_l
        elseif depth_field == 2
            top = Symbol(split(string(rhs), '.')[1])
            field = Symbol(split(string(rhs), '.')[2])
            expr_l = Expr(:(=),esc(top), Expr(:tuple, Expr(:(...), esc(top)), Expr(:(=), esc(field) ,(Expr(:tuple, Expr(:parameters, Expr(:(...),esc(rhs)), Expr(:(=), esc(s), esc(rn))))))))
        end
    end
    Expr(:block,lines...)
end

macro pack_land(outparams)
    @assert outparams.head == :block
    outputs = processPackingLine.(filter(i->isa(i,Expr),outparams.args))
    Expr(:block,outputs...)
end

land = (; pools=(land.pools..., a=2))
land = (; pools=(land.pools..., a=2))