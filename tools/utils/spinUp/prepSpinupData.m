function fSpin	=	prepSpinupData(f,info)
% prepare the forcing for spinup
if info.tem.spinup.flags.recycleMSC
    % do a mean season cycle
    fSpin	= f;
    fns     = fieldnames(f);
    for jj  = 1:numel(fns)
        if strcmpi(fns{jj},'Year'),continue,end
        tmp             =	f.(fns{jj});
        tmp             =	prepSpinupYear(tmp,f.Year,info);
        fSpin.(fns{jj})	=	tmp;
        YearSize        =   size(tmp);
    end
    % dummy year for the spinup
    fSpin.Year          = ones(YearSize,info.tem.model.rules.arrayPrecision) .* 1901;
else
    % use the transient forcing for the spinup
    fSpin	= f;
end

end % function