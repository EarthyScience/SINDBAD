function checkCAllocationVeg(f,fe,fx,s,d,p,info,i)

% values have to be between 0 and 1
dummy	= zeros(size(d.CAllocationVeg.cf2Root(:,i)));
for ii = {'cf2Root','cf2Wood','cf2Leaf'}%,'cf2RootCoarse'
    if any(d.CAllocationVeg.(ii{1})(:,i) > 1) || ...
            any(d.CAllocationVeg.(ii{1})(:,i) < 0)
        error(['SINDBAD : checkCAllocationVeg : CAllocationVeg.' ii{1} ' < 0 | > 1'])
    end
    dummy	= d.CAllocationVeg.(ii{1})(:,i) + dummy;
end
% sum must be one
if any(abs(dummy-1)>1E-10)
    error('SINDBAD : checkCAllocationVeg : total CAllocationVeg ~= 1')
end

end % function
