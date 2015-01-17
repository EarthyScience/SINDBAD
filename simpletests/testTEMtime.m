%% add the tem to the paths of matlab
addpath(strrep([pwd filesep '..' filesep 'tools' filesep 'dataproc' filesep],['simpletests' filesep '..' filesep],''),'-begin')
addpath(strrep([pwd filesep '..' filesep 'tools' filesep 'temSetUp' filesep],['simpletests' filesep '..' filesep],''),'-begin')
addpath(strrep([pwd filesep '..' filesep 'tools' filesep 'mexcdf' filesep 'snctools' filesep],['simpletests' filesep '..' filesep],''),'-begin')
addpath(strrep([pwd filesep '..' filesep 'model' filesep 'tem' filesep],['simpletests' filesep '..' filesep],''),'-begin')

%% load 1 year of data from a fluxnet site
fn          = [pwd filesep 'JunkData' filesep 'FR-Hes.1997.2006.daily.nc'];
f.Tair      = nc_varget(fn,'Tair_f')';          % daily temperature [ºC]
f.Tsoil     = nc_varget(fn,'Tsoil_f')';
f.TairDay   = nc_varget(fn,'Tair_f')';          % daytime temperature [ºC]
f.Rain      = nc_varget(fn,'precip_f')';        % dayly rainfall mm/day
f.RainInt   = nc_varget(fn,'precip_f')' ./ 10;  % rainfall intensity [mm/h]
f.Snow      = nc_varget(fn,'precip_f')' .* 0;   % snow fall [mm/day]
f.PsurfDay  = ones(size(f.Tair)) .* 100;        % atmospheric pressure during the daytime [kPa]
f.ca        = ones(size(f.Tair)) .* 360;
f.Rg        = nc_varget(fn,'Rg_f')';
f.RgPot     = nc_varget(fn,'Rg_pot')';
f.PAR       = nc_varget(fn,'Rg_f')' ./ 2;
f.Rn        = nc_varget(fn,'Rn_f')';            % net radiation [MJ/m2/day]
f.VPDDay    = nc_varget(fn,'VPD_f')';
f.PET       = nc_varget(fn,'Epot_f')';
f.FAPAR     = nc_varget(fn,'FAPAR')';
f.LAI       = nc_varget(fn,'FAPAR')' .* 4;
f.Year      = nc_varget(fn,'year')';
%% get the full setup of tem
NYears      = 10;
ForcingSize	= size(f.Tair);
info        = temFullSetup('info','timeScale.nYears',NYears,'spinUp.wPools',5,'forcing.size',ForcingSize,'spinUp.cPools',5000,'flags.genCode',0);
%% things to do before running the TEM


%% run tem
tic
tem(f,info);
toc

%%
info    = temFullSetup(...
        'info','timeScale.nYears',NYears,'spinUp.wPools',5,'forcing.size',ForcingSize,'spinUp.cPools',5000,'flags.genCode',1,'experimentName','expCodeGen01',...
        'ms','CCycle','none','AutoResp','none','CAllocationVeg','none','SoilMoistEffectRH','none');

    
    
tic
tem(f,info);
toc


