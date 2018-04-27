function fSpin	=	prepSpinupData(f,info)
fSpin	= f;
fns     = fieldnames(f);
for jj  = 1:numel(fns)
    if strcmpi(fns{jj},'Year'),continue,end
    tmp             =	f.(fns{jj});
    tmp             =	prepSpinupYear(tmp,f.Year,info);
    fSpin.(fns{jj})	=	tmp;
end
% dummy year for the spinup
fSpin.Year          = info.tem.helpers.arrays.onestix .* 1901;
end % function