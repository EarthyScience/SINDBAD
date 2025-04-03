using CairoMakie.Makie
function superscripts_to_float(superscripts)
    superscript_map = Dict('⁰' => '0', '¹' => '1', '²' => '2', '³' => '3', '⁴' => '4',
        '⁵' => '5', '⁶' => '6', '⁷' => '7', '⁸' => '8', '⁹' => '9', '⁻' => '-' # not needed
        )
    normal_digits = [superscript_map[c] for c in superscripts if c in keys(superscript_map)]    
    return parse(Float64, String(normal_digits))
end

function get_exponents(tlabels)
    return [get_exp(elem) for elem in tlabels]
end

function get_exp(l)
    _match = match(r"×10([\p{N}⁻]+)", l)
    if _match !== nothing
        return superscripts_to_float( _match.captures[1])
    else
        return 0
    end
end

function get_exp(l::Makie.RichText)
    if length(l.children)==2
        _exp = l.children[2].children[1]
        s_exp = split(_exp, "−")
        n_exp = length(s_exp)==2 ? "-" * s_exp[2] : s_exp[1]
        return parse(Float64, n_exp)
    else
        return 0
    end
end
