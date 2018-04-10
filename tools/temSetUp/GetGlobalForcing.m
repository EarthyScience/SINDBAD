function [info]=GetGlobalForcing(info)

%function requires the following fields in info:
%info.paths.spatialForcing;
%info.spatialRun.forcingDataSheet;
%info.spatialRun.yearlim;
%info.spatialRun.lonlim;
%info.spatialRun.latlim;


%

[info]=IniSpatialRunInfo(info);

%set's up spatial info (lat's, lon's, mask with missing values)
[info]=SetupSpatialInfo(info);

%define the tiles
[info]=InitialiseTiles4SpatialRun(info);

%fill tiles ...
[info]=FillForcingTiles(info);

end


function [VariableFlag, SindbadVariableNames, GlobalDataVariableNames, SpatialDataPaths, NCDFUnitToSindbadUnitMultiplier]=GetForcingMetaData(ForcingVars,ForcingVarsShort,VarInfo);



nv=length(ForcingVars);

VariableFlag=cell(nv,1);
SpatialDataPaths=cell(nv,1);
GlobalDataVariableNames=cell(nv,1);
SindbadVariableNames=cell(nv,1);
NCDFUnitToSindbadUnitMultiplier=NaN(nv,1);

tf=strcmp('SindbadVariableName',VarInfo(1,:));
ColSindbadVariableName=find(tf);

tf=strcmp('NCDFVariableName',VarInfo(1,:));
ColGlobalDataVariableName=find(tf);

tf=strcmp('VarTypeTimeSpace',VarInfo(1,:));
ColVarType=find(tf);

tf=strcmp('SpatialDataPath',VarInfo(1,:));
ColSpatialDataPath=find(tf);

tf=strcmp('NCDFUnitToSindbadUnitMultiplier',VarInfo(1,:));
ColNCDFUnitToSindbadUnitMultiplier=find(tf);

tf=strcmp('NameShort',VarInfo(1,:));
ColNameShort=find(tf);



for i=1:nv
    p=find(strcmp(ForcingVars(i),VarInfo(:,ColSindbadVariableName)) & strcmp(ForcingVarsShort(i),VarInfo(:,ColNameShort)));
    
    if isempty(p)
        mmsg=['Forcing for ' char(ForcingVarsShort(i)) ' not found'];
        warning(mmsg)
        
    else
        
        GlobalDataVariableNames(i)=VarInfo(p,ColGlobalDataVariableName);
        VariableFlag(i)=VarInfo(p,ColVarType);
        SpatialDataPaths(i)=VarInfo(p,ColSpatialDataPath);
        NCDFUnitToSindbadUnitMultiplier(i)=cell2mat(VarInfo(p,ColNCDFUnitToSindbadUnitMultiplier));
        SindbadVariableNames(i)=VarInfo(p,ColSindbadVariableName);
    end
    
    
end

end


function [info]=InitialiseTiles4SpatialRun(info)

%do it only if it does not exist yet
if ~isfield(info.spatialRun,'tileIdx')
    
    npsPerTile=100000;
    
    if isfield(info.spatialRun,'npsPerTile');
        if ~isempty(info.spatialRun.npsPerTile)
            npsPerTile=info.spatialRun.npsPerTile;
        end
    end
    
    mask=info.spatialRun.spatialInfo.mask;
    %define the tiles
    idxall=find(mask);
    nps=length(idxall);
    
    ntiles=round(nps/npsPerTile);
    
    tileStruct=struct;
    
    for i=1:ntiles
        p1=(i-1)*npsPerTile+1;
        p2=min(p1+npsPerTile-1,npt);
        idx=idxall(p1:p2);
        tileStruct(i).tileIdx=idx;
    end
    
    info.spatialRun.tileIdx=tileStruct;
    %%%%
end
end


function [info]=SetupSpatialInfo(info)


%%%%get lat lon stuff
i=1;
if strcmp('spatial',VariableFlag(i))
    ff=dir([lp char(GlobalDataVariableNames(i)) '*.nc']);
    lp2=[char(SpatialDataPaths(i)) ff(1).name];
else
    ff=dir([lp char(GlobalDataVariableNames(i)) '*' year1 '.nc']);
    lp2=[char(SpatialDataPaths(i)) ff(1).name];
end

lat=ncread(lp2,'lat'); %use first one arbitrarily
lon=ncread(lp2,'lon');

[c, StartLat] = min(abs(lat-max(latlim)));
[c, StartLon] = min(abs(lon-min(lonlim)));

[c, EndLat] = min(abs(lat-min(latlim)));
[c, EndLon] = min(abs(lon-max(lonlim)));

latout = lat(StartLat:EndLat);
lonout = lon(StartLon:EndLon);

CountLat=EndLat-StartLat+1;
CountLon=EndLon-StartLon+1;



%store that shit in info.spatialRun.spatialInfo
%%%%%%%%%%%%%%%%%%%%%%
info.spatialRun.spatialInfo.latout=latout;
info.spatialRun.spatialInfo.lonout=lonout;
info.spatialRun.spatialInfo.CountLat=CountLat;
info.spatialRun.spatialInfo.CountLon=CountLon;
info.spatialRun.spatialInfo.IdxStartLat=StartLat;
info.spatialRun.spatialInfo.IdxEndLat=EndLat;
info.spatialRun.spatialInfo.IdxStartLon=StartLon;
info.spatialRun.spatialInfo.IdxEndLon=EndLon;

%do a mask%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mask=true(rows,cols);

for i=1:length(ForcingVars)
    lp=[char(SpatialDataPaths(i))];
    %disp(char(GlobalDataVariableNames(i)))
    
    if strcmp('spatial',VariableFlag(i))
        ff=dir([lp char(GlobalDataVariableNames(i)) '*.nc']);
        lp2=[lp ff(1).name];
        
        dat=ncread(lp2,char(GlobalDataVariableNames(i)),[StartLon StartLat],[CountLon CountLat]);
    else
        ff=dir([lp char(GlobalDataVariableNames(i)) '*' num2str(year1) '.nc']);
        lp2=[lp ff(1).name];
        
        dat=ncread(lp2,char(GlobalDataVariableNames(i)),[StartLon StartLat 1],[CountLon CountLat 1]);
    end
    
    %read and check also for missing value data
    mask(isnan(dat))=0;
end

info.spatialRun.spatialInfo.mask=mask;
end

function [info]=IniSpatialRunInfo(info)

AllVars=info.variables.input;
tf=strncmp('f.',AllVars,2);
ForcingVars=AllVars(tf);

pthVariableInfo=info.paths.spatialForcing;

forcingDataSheet=info.spatialRun.forcingDataSheet;
[num,txt,VarInfo]=xlsread(pthVariableInfo,'all');
[num,txt,ForcingVarsShort]=xlsread(pthVariableInfo,forcingDataSheet);

%match forcing vars and forcing vars short here
ForcingVarsShort2=ForcingVarsShort;
for i=1:length(ForcingVars)
    %find in ForcingVarsShort using convention variableName_productName
    cfn=[char(ForcingVars(i)) '_'];
    tf=find(strncmp(cfn,ForcingVarsShort,length(cfn)));
    if isempty(tf)
        mmsg=['No spatial forcing data available for ' cfn(1:end-1)];
        warning(mmsg)
    else
        ForcingVarsShort2(i)=ForcingVarsShort(tf);
    end
end
ForcingVarsShort=ForcingVarsShort2;

[VariableFlag, SindbadVariableNames, GlobalDataVariableNames, SpatialDataPaths, NCDFUnitToSindbadUnitMultiplier]=GetForcingMetaData(ForcingVars,ForcingVarsShort,VarInfo);

info.spatialRun.variables.forcingVarNamesShort=ForcingVarsShort;
info.spatialRun.variables.forcingVars=ForcingVars;
info.spatialRun.variables.forcingVarsSindbad=SindbadVariableNames;
info.spatialRun.variables.forcingVarsNCDF=GlobalDataVariableNames;
info.spatialRun.variables.variableType=VariableFlag;
info.spatialRun.variables.NCDFUnitToSindbadUnitMultiplier=NCDFUnitToSindbadUnitMultiplier;
info.paths.spatialForcingFiles=SpatialDataPaths;
%store that shit in info.spatialRun.forcingInfo; store the data paths in
%info.paths (easier to manipulate if all stored in the same place (mac vs
%pc vs linux)
end


function [info]=FillForcingTiles(info);



SindbadVariableNames=info.spatialRun.variables.forcingVarsSindbad;
GlobalDataVariableNames=info.spatialRun.variables.forcingVarsNCDF;
VariableFlag=info.spatialRun.variables.variableType;
NCDFUnitToSindbadUnitMultiplier=info.spatialRun.variables.NCDFUnitToSindbadUnitMultiplier;
SpatialDataPaths=info.paths.spatialForcingFiles;



%info.spatialRun
yearlim=info.spatialRun.yearlim;
year1=min(yearlim);
year2=max(yearlim);
nyears=year2-year1+1;

YearDoy=[];
nleapyears=0;
for y=year1:year2
    n=365;
    if isleap(y)
        nleapyears=nleapyears+1;
        n=366;
    end
    tmp=horzcat(zeros(n,1)+y,(1:n)');
    YearDoy=vertcat(YearDoy,tmp);
end
npt=nyears*365+nleapyears; %this is for daily!!!!! use time step info in info.???

%possible problems: leap years



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get variables and distribute to tiles

for t=1:ntiles
    idx=f_info.tiles.idx(t).idx;
    nidx=length(idx);
    f=struct;
    
    for i=1:length(Vars)
        ctile=zeros(npt,nidx,'single');
        %get variable
        lp=[char(SpatialDataPaths(i))];
        %disp(char(GlobalDataVariableNames(i)))
        
        switch char(VariableFlag(i))
            case 'spatial'
                ff=dir([lp char(GlobalDataVariableNames(i)) '*.nc']);
                lp2=[lp ff(1).name];
                
                dat=ncread(lp2,char(GlobalDataVariableNames(i)),[StartLon StartLat],[CountLon CountLat]);
                
                for ii=1:npt
                   ctile(ii,:)=dat(idx).*NCDFUnitToSindbadUnitMultiplier; 
                end
            case 'seasonal'
                
                ff=dir([lp char(GlobalDataVariableNames(i)) '*.nc']);
                lp2=[lp ff(1).name];
                
                dat=ncread(lp2,char(GlobalDataVariableNames(i)),[StartLon StartLat Inf],[CountLon CountLat Inf]);
                
                for y=year1:year2                                        
                    [ctile]=Dat2Tile(dat,ctile,y,YearDoy,idx,NCDFUnitToSindbadUnitMultiplier(i));                    
                end
                
            case 'normal'
                
                
                for y=year1:year2
                    
                    ff=dir([lp char(GlobalDataVariableNames(i)) '*' num2str(y) '.nc']);
                    lp2=[lp ff(1).name];
                    
                    dat=ncread(lp2,char(GlobalDataVariableNames(i)),[StartLon StartLat Inf],[CountLon CountLat Inf]);
                    
                    [ctile]=Dat2Tile(dat,ctile,y,YearDoy,idx,NCDFUnitToSindbadUnitMultiplier(i));
                    
                end
        end
        
        
    end
    %save tile
    %check here for inf nan bounds?
    %store tile path ....
end
end

function [ctile]=Dat2Tile(dat,ctile,y,YearDoy,idx,NCDFUnitToSindbadUnitMultiplier);

cnpt=length(dat(1,1,:));

for ii=1:cnpt
    cdat=squeeze(dat(:,:,ii));
    p=find(YearDoy(:,1)==y & YearDoy(:,2)==ii);
    
    ctile(p,:)=cdat(idx).*NCDFUnitToSindbadUnitMultiplier;
end

if isleap(y)
    
    if cnpt~=366
        %replicate doy 365
        cdat=squeeze(dat(:,:,365));
        p=find(YearDoy(:,1)==y & YearDoy(:,2)==366);
        ctile(p,:)=cdat(idx).*NCDFUnitToSindbadUnitMultiplier;
    end
    
end
end