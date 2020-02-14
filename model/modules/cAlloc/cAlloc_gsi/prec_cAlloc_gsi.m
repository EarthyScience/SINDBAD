function [f,fe,fx,s,d,p] = prec_cAlloc_gsi(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % set to 1 the 1st time step of the moisture, temperature and radiations effects on decomposition/mineralization
    d.cAlloc.fWfTfR(:,1) =  1;

    % % set the allocation to zeros
    % s.cd.cAlloc=zeros(pix,zix);
    s.cd.cAlloc     =   info.tem.helpers.arrays.zerospixzix.c.cEco; %sbesnard
    end
    
    