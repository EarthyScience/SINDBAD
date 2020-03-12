function [f, fe, fx, s, d, p] = prec_cTaufwSoil_none(f, fe, fx, s, d, p, info)
    % set the outputs to ones
    d.cTaufwSoil.fwSoil = info.tem.helpers.arrays.onespixtix;
end
