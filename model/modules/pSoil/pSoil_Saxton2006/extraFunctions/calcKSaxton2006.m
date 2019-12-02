function K = calcKSaxton2006(s,p,info,sl)
% calculates the soil hydraulic conductivity for a given moisture content based on Saxton 2006
%
% Inputs:
%	- info  
%	- p.pSoil.sand, p.soilTexture.silt and other soil texture-based properties
%
% Outputs:
%   - properties of moisture-retention curves (Alpha and Beta)
%   - hydraulic conductivity (k), matric potention (psi) and porosity
%   (theta) at saturation (Sat), field capacity (FC), and wilting point
%   (WP)
%
% Modifies:
% 	- None
%
% References:
%  - Saxton, K. E., & Rawls, W. J. (2006). Soil water characteristic estimates by texture and organic matter
%      for hydrologic solutions. Soil science society of America Journal, 70(5), 1569-1578.
% 
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala):
%
%% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wSat            =   s.wd.p_wSoilBase_wSat(:,sl);
Theta_dos       =   s.w.wSoil(:,sl) ./ wSat;
if p.wSoilBase.makeLookup
    Beta            =   s.wd.p_wSoilBase_Beta(:,sl);
    kSat            =   s.wd.p_wSoilBase_kSat(:,sl);
    lambda          =   1 ./ Beta;
    % -------------------------------------------------------------------------
    % WATER CONDUCTIVITY (mm/day)
    K               =   kSat .* ((Theta_dos) .^ (3 + (2 ./ lambda)));
    % -------------------------------------------------------------------------
else
    lkDat                                       =   squeeze(s.wd.p_wSoilBase_kLookUp(:,sl,:));
    Theta_dos(Theta_dos<0) = 0;
    Theta_dos(imag(Theta_dos)~=0) = 0;
    if size(lkDat,2) == 1
        lkDat       = lkDat';
    end
    
    lkInd                                       =   floor(Theta_dos .* p.wSoilBase.nLookup);
    lkInd(lkInd==0)                             =   1;
    lkInd(lkInd>p.wSoilBase.nLookup)            =   p.wSoilBase.nLookup;
    idxArray= zeros(size(lkDat));
    for i = 1: length(lkDat)
        idxArray(i,lkInd(i)) = 1;
    end
        K                                           =   lkDat(idxArray ==1);
%     K  = K(:,1);
%     K                                           =   lkInd;
%     lkInd(lkInd==0)                             =   1;
%     lkInd(lkInd>p.wSoilBase.nLookup)            =   p.wSoilBase.nLookup;
%     K = lkDat(:,lkInd);
end
% a=rand(904,1);
% b=repmat(rng',1,size(a,1))';
% c=abs(a-b);
% d=c*0;
% d(c==min(c,[],2))=1;

end
