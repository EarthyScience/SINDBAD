function setvar_out = fillDataGaps(var,var_flag,varname,missval,dt)
% previous: gapfill
% fills smaller gaps in meteo forcing
% Input:
%   var the variable to be filled (double)
%   varname the name of the variable (just for error messages) (string)

%%CONSTANTS
search_radius=15; %days around missing value to be searched

%find gaps
isgap=missval==var|isnan(var)|isinf(var);
pos = find(isgap);
nstep=length(var);
ngap = length(pos);

%% No gaps, return to main programm
if ( isempty(pos) )
    
    sstr    =   [pad('MSG GAPS',20) ' : ' pad('fillDataGaps',20) ' | ' 'Gapfilling not needed for ' varname];
    disp(sstr)
    setvar_out={var var_flag};
    return
end

%% some internal calculations
spos=-1*search_radius:search_radius;

%determine whether we are dealing with daily or hourly values
if ~exist('dt', 'var')
    if(rem(nstep,365)==0)||(rem(nstep,366)==0)
        dt=1;
    elseif(rem(nstep,17520)==0)||(rem(nstep,17568)==0)
        dt=48;
    else
        sstr    =   [pad('CRIT GAPS',20) ' : ' pad('fillDataGaps',20) ' | ' 'Time steps unknown for gap filling'];
        error(sstr)
    end
end
%% Mark gaps in flag vector
var_flag(pos)=0;

%% Case 1: the gaps is between less then three timesteps long
%  use linear interpolation
varout=var;

for n =  1:length(pos)
    if( (pos(n)>2) && (pos(n)<length(var)-1))
        if (isgap(pos(n)-1)==0 && isgap(pos(n)+1)==0)
            varout(pos(n))=(var(pos(n)-1)+var(pos(n)+1))/2.;
        elseif (isgap(pos(n)-2)==0 && isgap(pos(n)+1)==0)
            varout(pos(n))=var(pos(n)+1)+(var(pos(n)-2)-var(pos(n)+1))/3.;
        elseif (isgap(pos(n)-1)==0 && isgap(pos(n)+2)==0)
            varout(pos(n))=var(pos(n)-1)-(var(pos(n)-1)-var(pos(n)+2))/3.;
        end
    end
end

%% still gaps?
% isgap=missval==varout;
isgap=missval==varout|isnan(varout)|isinf(varout);
ngap2 = length(find(isgap));
sstr    =   [pad('MSG FILLED GAPS',20) ' : ' pad('fillDataGaps',20) ' | ' 'filled ' num2str(ngap-ngap2) ' gaps using linear interpolation for ' varname];
disp(sstr)
if( ngap2 == 0 )
    sstr    =   [pad('MSG GAPS',20) ' : ' pad('fillDataGaps',20) ' | ' 'Gapfilling not needed for ' varname];
    disp(sstr)
    setvar_out={varout var_flag};
    return
end

%% Case 2: the gaps is longer than three time steps
%  use mean state of the previous and following days within the search
%  radius and at the same time of the day
var=varout;
% isgap=missval==var;
isgap=missval==var|isnan(var)|isinf(var);
pos = find(isgap);
for n=1:length(pos);
    tpos=spos*dt+pos(n);
    %avoid array pos < 0
    tpos=tpos(tpos>0);
    %avoid array pos > array length
    tpos=tpos(tpos<=nstep);
    %ignore positions that are missing values
    tpos=tpos(~isgap(tpos));
    if(length(tpos)>0)
        varout(pos(n))=mean(var(tpos));
    else
        varout(pos(n))=missval;
    end
end

%% still gaps?
% isgap=missval==varout;
isgap=missval==varout|isnan(varout)|isinf(varout);
ngap3 = length(find(isgap));
sstr    =   [pad('MSG FILLED GAPS',20) ' : ' pad('fillDataGaps',20) ' | ' 'filled ' num2str(ngap2-ngap3) ' gaps by average conditions around gap (' num2str(search_radius) ') for ' varname];
disp(sstr)
if(ngap3 > 0)
    sstr    =   [pad('CRIT REM GAPS',20) ' : ' pad('fillDataGaps',20) ' | ' 'gapfilling not sucessful for ' varname ':' num2str(ngap3) ' gaps remaining'];
    disp(sstr)
    var=varout;
    varout(isgap)=mean(var(var~=missval&isnan(var)==0&isinf(var)==0));
    sstr    =   [pad('MSG FILLED GAPS',20) ' : ' pad('fillDataGaps',20) ' | ' 'fgap filled using average conditions: ',num2str(mean(var(var~=missval&isnan(var)==0&isinf(var)==0)))];
disp(sstr)
end

setvar_out={varout var_flag};
