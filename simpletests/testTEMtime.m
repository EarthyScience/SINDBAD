%% add the tem to the paths of matlab
addpath(strrep([pwd filesep '..' filesep 'tools' filesep 'dataproc' filesep],['simpletests' filesep '..' filesep],''),'-begin')
addpath(strrep([pwd filesep '..' filesep 'tools' filesep 'timeutils' filesep],['simpletests' filesep '..' filesep],''),'-begin')
addpath(strrep([pwd filesep '..' filesep 'tools' filesep 'temSetUp' filesep],['simpletests' filesep '..' filesep],''),'-begin')
addpath(strrep([pwd filesep '..' filesep 'tools' filesep 'mexcdf' filesep 'snctools' filesep],['simpletests' filesep '..' filesep],''),'-begin')
addpath(strrep([pwd filesep '..' filesep 'tools' filesep 'mexcdf' filesep 'mexnc' filesep],['simpletests' filesep '..' filesep],''),'-begin')
addpath(strrep([pwd filesep '..' filesep 'model' filesep 'tem' filesep],['simpletests' filesep '..' filesep],''),'-begin')

%% load 1 year of data from a fluxnet site
fn          = [pwd filesep 'JunkData' filesep 'FR-Hes.1997.2006.daily.nc'];
f.Tair      = nc_varget(fn,'Tair_f')';          % daily temperature [ºC]
f.Tsoil     = nc_varget(fn,'Tsoil_f')';         % daily soil temperature [ºC]
f.TairDay   = nc_varget(fn,'Tair_f')';          % daytime temperature [ºC]
f.Rain      = nc_varget(fn,'precip_f')';        % dayly rainfall mm/day
f.Snow      = zeros(size(f.Rain));              % snow fall [mm/day]
ndx         = f.Tair < 0;
f.Snow(ndx) = f.Rain(ndx);
f.Rain(ndx) = 0;
f.RainInt   = nc_varget(fn,'precip_f')' ./ 10;  % rainfall intensity [mm/h]
f.PsurfDay  = ones(size(f.Tair)) .* 100;        % atmospheric pressure during the daytime [kPa]
f.ca        = ones(size(f.Tair)) .* 360;        % atmospheric co2 concentration [ppm]
f.Rg        = nc_varget(fn,'Rg_f')';            % incoming global radiation [MJ/m2/day]
f.RgPot     = nc_varget(fn,'Rg_pot')';          % potential incoming global radiation [MJ/m2/day]
f.Rg(f.Rg<0)= f.RgPot(f.Rg<0);
f.PAR       = nc_varget(fn,'Rg_f')' ./ 2;       % incoming photosynthetically active radiation [MJ/m2/day]
f.Rn        = nc_varget(fn,'Rn_f')';            % net radiation [MJ/m2/day]
f.VPDDay    = nc_varget(fn,'VPD_f')';           % vapor pressure deficit [kPa]
f.PET       = nc_varget(fn,'EpotPT_viaRn')';          % potential evapotraspiration [mm/day]
f.PET(f.PET<0)= 0;
f.FAPAR     = ones(size(nc_varget(fn,'FAPAR')))'-0.1;
f.LAI       = f.FAPAR .* 4;
f.Year      = nc_varget(fn,'year')';
%% 
g=fieldnames(f);
for i = 1:numel(g)
    tmp = getfield(f,g{i});
    tmp = tmp(1:365);
    eval(['f.' g{i} ' = tmp;'])
end

%% get the full setup of tem
NYears      = 10;
ForcingSize	= size(f.Tair);
%%
info        = temFullSetup('info','timeScale.nYears',1,'spinUp.wPools',5,'forcing.size',ForcingSize,'spinUp.cPools',5000,'flags.genCode',1,'spinUp.cycleMSC',1);
tic
[fx,s,d,sSU,dDU,fe] = tem(f,info);
toc
%%
info        = temFullSetup('info','timeScale.nYears',NYears,'spinUp.wPools',1,'forcing.size',ForcingSize,'spinUp.cPools',500,'flags.genCode',1,'spinUp.cycleMSC',0);
tic
[fx,s,d,sSU,dDU] = tem(f,info);
toc
%%
tic
[fe,fx,d,p]=info.code.msi.preComp(f,fe,fx,s,d,info.params,info);
[s, fx, d] = info.code.msi.core(f,fe,fx,s,d,info.params,info);
toc

%%
info    = temFullSetup(...
        'info','timeScale.nYears',NYears,'spinUp.wPools',5,'forcing.size',ForcingSize,'spinUp.cPools',5000,'flags.genCode',1,'experimentName','expCodeGen01',...
        'ms',...
        'SnowCover'         , 'binary'          ,...
        'Sublimation'       , 'GLEAM'            ,...
        'SnowMelt'          , 'simple'          ,...
        'Interception'      , 'Gash'            ,...    % 2 - Water 
        'RunoffInfE'        , 'none'            ,...    % 2 - Water 
        'SaturatedFraction' , 'none'            ,...    % 2 - Water 
        'RunoffSat'         , 'Zhang'            ,...    % 2 - Water 
        'RechargeSoil'      , 'TopBottom'       ,...    % 2 - Water 
        'RunoffInt'         , 'none'          ,...    % 2 - Water 
        'RechargeGW'        , 'simple'            ,...    % 2 - Water 
        'BaseFlow'          , 'simple'            ,...    % 2 - Water 
        'SoilMoistureGW'    , 'none'            ,...    % 2 - Water 
        'SoilEvap'          , 'simple'            ,...    % 2 - Water 
        'WUE'               , 'Medlyn'            ,...    % 2 - Water 
        'SupplyTransp'      , 'Federer'            ,...    % 3 - Transpiration and GPP
        'LightEffectGPP'    , 'none'            ,...    % 3 - Transpiration and GPP
        'MaxRUE'            , 'Monteith'        ,...    % 3 - Transpiration and GPP
        'TempEffectGPP'     , 'CASA'            ,...    % 3 - Transpiration and GPP
        'VPDEffectGPP'      , 'none'            ,...    % 3 - Transpiration and GPP
        'DemandGPP'         , 'mult'            ,...    % 3 - Transpiration and GPP
        'SMEffectGPP'       , 'Supply'            ,...    % 3 - Transpiration and GPP
        'ActualGPP'         , 'mult'            ,...    % 3 - Transpiration and GPP
        'Transp'            , 'Coupled'            ,...    % 3 - Transpiration and GPP
        'RootUptake'        , 'TopBottom'       ,...    % 3 - Transpiration and GPP
        'SoilMoistEffectRH' , 'none'            ,...    % 4 - Climate effects on metabolic processes
        'TempEffectRH'      , 'none'            ,...    % 4 - Climate effects on metabolic processes
        'TempEffectAutoResp', 'none'            ,...    % 4 - Climate effects on metabolic processes
        'CAllocationVeg'    , 'none'            ,...    % 5 - Allocation of C within plant organs
        'AutoResp'          , 'none'            ,...    % 6 - Autotrophic respiration
        'CCycle'            , 'none'            ...     % 7 - Carbon Cycle / Heteroptrophic Respiration
        );
    
info.params.RunoffInt.rc = 1;
% jday                        = nc_varget(fn,'julday')';
% lat                         = nc_varget(fn,'latitude')';
%%
% f.PET = calc_pet_Thornthwaite(f.Tair, jday, f.Year, lat, 'casa', '1day');

%
    %%
tic
[fx,s,d,sSU,dDU] = tem(f,info);
toc
%%
tic
[fe,fx,d,p]=info.code.msi.preComp(f,fe,fx,s,d,info.params,info);
[s, fx, d] = info.code.msi.core(f,fe,fx,s,d,info.params,info);
toc
%%
%
%
gpp= nc_varget(fn,'GPP_f')';
et= nc_varget(fn,'Ecov_f')';

figure,hold on,plot(fx.gpp,'r-'),plot(gpp(1:numel(fx.gpp)),'b-'),legend({'sindbad','fluxnet'}),title('gpp')
figure,hold on,plot(fx.Transp,'r-'),plot(et(1:numel(fx.Transp)),'b-'),legend({'sindbad','fluxnet'}),title('et')
%
g=fieldnames(fx);
for i = 1:numel(g)
    tmp = getfield(fx,g{i});
    if isstruct(tmp),continue,end
    figure,plot(tmp),title(strrep(g{i},'_','\_'))
end

g=fieldnames(s);
for i = 1:numel(g)
    tmp = getfield(s,g{i});
    if isstruct(tmp),continue,end
    figure,plot(tmp),title(strrep(g{i},'_','\_'))
end

figure,plot(s.wSM1+s.wSM2)

%%
g=fieldnames(f);
for i = 1:numel(g)
    tmp = getfield(f,g{i});
    if isstruct(tmp),continue,end
    figure,plot(tmp),title(strrep(g{i},'_','\_'))
end



