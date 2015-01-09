function fSpin = mkSpinUpData(f,info)
fSpin	= f;
fns     = fieldnames(f);
for jj = 1:numel(fns)
    if strcmpi(fns{jj},'Year'),continue,end
    tmp             = f.(fns{jj});
    tmp             = mkSpinUpYear(tmp,f.Year,info);
    fSpin.(fns{jj})	= tmp;
end
% dummy year for the spinup
fSpin.Year	= ones(1,size(f.Tair,2)) .* 1901;
end % function