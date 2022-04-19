
function processCreateArray(ex)
	@assert ex.head == :(=) 
    lhs = ex.args[1]
    rhs = ex.args[2]
    if lhs isa Symbol
        lhs = [lhs]
    elseif lhs.head == :tuple
        lhs = lhs.args
    else
        error("processCreateArray: could not create:" * lhs * "=" * rhs)
    end
    lines = map(lhs) do s
		expr_l = Expr(:(=), Symbol(s), Expr(:call, Expr(:repeat, esc(rhs.args[1]), esc(rhs.args[2]))))
            expr_l
    end
    Expr(:block, lines...)
end

macro create_arrays(outparams)
    @assert outparams.head == :block || outparams.head == :call || outparams.head == :(=)
    if outparams.head == :block
        outputs = processCreateArray.(filter(i -> isa(i, Expr), outparams.args))
        outCode = Expr(:block, outputs...)
    else
        outCode = processCreateArray(outparams)
    end
    return outCode
end

infotem = (; helpers=(; aone = [1]), pools=(;water=(; nZix=(;soilW=5))))
@create_arrays ("p_CLAY", "p_SAND", "p_SILT", "p_ORGM", "p_soilDepths", "p_wFC", "p_wWP", "p_wSat", "p_kSat", "p_kFC", "p_kWP", "p_ψSat", "p_ψFC", "p_ψWP", "p_θSat", "p_θFC", "p_θWP", "p_α", "p_β") = (infotem.helpers.aone, infotem.pools.water.nZix.soilW)
