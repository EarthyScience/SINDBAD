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
f.RainInt   = nc_varget(fn,'precip_f')' ./ 10;  % rainfall intensity [mm/h]
f.Snow      = nc_varget(fn,'precip_f')' .* 0;   % snow fall [mm/day]
f.PsurfDay  = ones(size(f.Tair)) .* 100;        % atmospheric pressure during the daytime [kPa]
f.ca        = ones(size(f.Tair)) .* 360;        % atmospheric co2 concentration [ppm]
f.Rg        = nc_varget(fn,'Rg_f')';            % incoming global radiation [MJ/m2/day]
f.RgPot     = nc_varget(fn,'Rg_pot')';          % potential incoming global radiation [MJ/m2/day]
f.Rg(f.Rg<0)= f.RgPot(f.Rg<0);
f.PAR       = nc_varget(fn,'Rg_f')' ./ 2;       % incoming photosynthetically active radiation [MJ/m2/day]
f.Rn        = nc_varget(fn,'Rn_f')';            % net radiation [MJ/m2/day]
f.VPDDay    = nc_varget(fn,'VPD_f')';           % vapor pressure deficit [kPa]
f.PET       = nc_varget(fn,'Epot_f')';          % potential evapotraspiration [mm/day]
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
NYears      = 1;
ForcingSize	= size(f.Tair);
info        = temFullSetup('info','timeScale.nYears',NYears,'spinUp.wPools',5,'forcing.size',ForcingSize,'spinUp.cPools',5000,'flags.genCode',0);
%% things to do before running the TEM


%% run tem
tic
[fx,s,d,sSU,dDU] = tem(f,info);
toc

%%
info    = temFullSetup(...
        'info','timeScale.nYears',NYears,'spinUp.wPools',5,'forcing.size',ForcingSize,'spinUp.cPools',5000,'flags.genCode',1,'experimentName','expCodeGen01',...
        'ms','CCycle','none','AutoResp','none','CAllocationVeg','none','SoilMoistEffectRH','none');

%%    
    
tic
[fx,s,d,sSU,dDU] = tem(f,info);
toc
%%
g=fieldnames(fx);
for i = 1:numel(g)
    tmp = getfield(fx,g{i});
    if isstruct(tmp),continue,end
    figure,plot(tmp),title(strrep(g{i},'_','\_'))
end
%%
g=fieldnames(f);
for i = 1:numel(g)
    tmp = getfield(f,g{i});
    if isstruct(tmp),continue,end
    figure,plot(tmp),title(strrep(g{i},'_','\_'))
end

