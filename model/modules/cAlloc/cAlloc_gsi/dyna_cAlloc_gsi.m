function [f,fe,fx,s,d,p] = dyna_cAlloc_gsi(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % compute the fraction of NPP that is allocated to the
    % different plant organs. In this case, the allocation is dynamic in time
    % according to temperature, water and radiation stressors computed from GSI approach.
    %
    % Inputs:
    %   - d.cAllocfwSoil.fW:    water stressors for carbon allocation
    %   - d.cAllocfwSoil.fT:    temperature stressors for carbon allocation 
    %   - d.cAllocfRad.fR:      radiation stressors for carbo allocation 
    %   - p.cAlloc.LR2ReSlp:    carbon allocation from leave/root to reserve
    %   - p.cAlloc.Re2LRSlp:    carbon allocation from reserve to leave/roots
    %   - p.cAlloc.kShed:       carbon allocation to litter from shedding
    %
    % Outputs:
    %   - s.cd.cAlloc: the fraction of NPP that is allocated to the different plant organs 
    %
    % Modifies:
    %   - s.cd.cAlloc
    %
    % References:
    %   -  Jolly, William M., Ramakrishna Nemani, and Steven W. Running. "A generalized, bioclimatic index to predict foliar phenology in response to climate." Global Change Biology 11.4 (2005): 619-632.
    %
    % Created by:
    %   - ncarvalhais and sbesnard 
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % allocation to root, wood and leaf
    cf2.cVegLeaf = d.cAllocfwSoil.fW(:,tix)./(d.cAllocfwSoil.fW(:,tix)+d.cAllocfTsoil.fT(:,tix))./2;
    cf2.cVegWood = d.cAllocfwSoil.fW(:,tix)./(d.cAllocfwSoil.fW(:,tix)+d.cAllocfTsoil.fT(:,tix))./2;
    cf2.cVegRoot = d.cAllocfTsoil.fT(:,tix)./(d.cAllocfwSoil.fW(:,tix)+d.cAllocfTsoil.fT(:,tix));
    
    % Estimate allocation to reserve vs. leave, root and shed
    pcAlloc_fWfTfR = d.prev.d_cAlloc_fWfTfR;
    cAlloc_fWfTfR = d.cAllocfwSoil.fW(:,tix) * d.cAllocfTsoil.fT(:,tix) * d.cAllocfRad.fR(:,tix);
    LR2Re   =  min(max(pcAlloc_fWfTfR-cAlloc_fWfTfR,0).*p.cAlloc.LR2ReSlp,1); % if DAS degrades, mobilize c to reserves
    Re2LR   =  min(max(pcAlloc_fWfTfR-cAlloc_fWfTfR,0).*p.cAlloc.Re2LRSlp,1); % if DAS increases, mobilize c to leafs and roots
    kShed   =  min(max(pcAlloc_fWfTfR-cAlloc_fWfTfR,0).*p.cAlloc.kShed,1);    % if DAS degrades increase c to litter

    % Update allocation to root, leaf and reserve based on DAS
    cf2.cVegLeaf = cf2.cVegLeaf + Re2LR ./2 - LR2Re ./2;
    cf2.cVegRoot = cf2.cVegRoot + Re2LR ./2 - LR2Re ./2;
    cf2.cVegReserve = LR2Re - Re2LR;

    % distribute the allocation according to pools...
    cpNames = {'cVegRoot','cVegWood','cVegLeaf', 'cVegReserve'};
    for cpn = 1:numel(cpNames)
        zixVec = info.tem.model.variables.states.c.zix.(cpNames{cpn});
        N      = numel(zixVec);
        for zix = zixVec
            s.cd.cAlloc(:,zix)	= cf2.(cpNames{cpn}) ./ N;
        end
    end
    
    % check allocation...
    tmp0 = s.cd.cAlloc(:); %sujan
    tmp1 = sum(s.cd.cAlloc,2);
    if any(tmp0 > 1) || any(tmp0 < 0)
         error('SINDBAD TEM dyna_cAlloc_gsi: cAlloc lt 0 or gt 1')
    end
    if any(abs(sum(tmp1,2)-1) > 1E-6)
          error('SINDBAD TEM dyna_cAlloc_gsi: sum(cAlloc) ne 1')
    end
    end
    
    




    