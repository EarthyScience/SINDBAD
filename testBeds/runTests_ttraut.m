% a script to run the diagnostic tests of SINDBAD when new developments
% have been made.
% In order to maintain backward compaatibility of the model, the MERGE
% REQUEST TO THE MASTER WILL BE HANDLED ONLY WHEN THE TESTS ARE SUCCESSFULLY EXECUTED
%
%% case 1:
% - Domain: Random 25 grid cells in the northern hemisphere
% - Purpose: to test if the carbon cycle spinups are running
% - Runs: Explicit, Impicit, and Reduced Explicit modes of spinup for CASA
% and simple model structures
% - Produces: Figures comparing each of these model simulations and spinup.
% - Outcomes:
%   - 1:1 results of carbon storages for explicit vs reduced explicit for both CASA and simple
%   - near 1:1 results of carbon storages for implicit vs explict or casa vs simple
%
%% case 2:
% - overview: optimize carbon cycle parameters for a fluxnet site
% - Domain: An example fluxnet site
% - Purpose: to test if optimization of the carbon cycle is running
% - Runs: Model with default parameters, and optimization with cmaes for 20 iterations.
% - Produces: Runs and finishes without errors. Does not produce the final optimized parameters.
% - Outcomes:
%   - figures comparing the fields of f, fx, and d.StoredStates. for
%   default and parameters at the end of optimization
%   - all the variables that are not affected by the optimized parameters
%   should be on 1:1 line
%   - carbon cycle variables should divert from 1:1 line (e.g., cRa, cEco,
%   RECO, RA,RH, NPP, gpp)
%   - indirectly tests if the implicit spinup of carbon cycle is running
%
%% case 3:
% - overview: forward run water cycle
% - Domain: 1000 grids in the northern hemisphere
% - Purpose: to test if water cycle model is running
% - Runs: generated code, handles, and generated code with reduced memory arrays
% - Produces: figures comparing the fields of f, fx, and d.StoredStates for
% above simulations
% - Outcomes:
%   - 1:1 results of all compared fields.
%
%% case 4:
% - overview: optimization of the water cycle
% - Domain: 904 grid cells globally distributed
% - Purpose: to test if the optimization of the water cycle model is running
% - Runs: model with pre-optimized parameters, and optimization with cmaes for 10 iterations.
% - Produces: Runs and finishes without errors. Does not produce the final optimized parameters.
% - Outcomes:
%   - figures comparing the fields of f, fx, and d.StoredStates. for
%   pre-optimized parameters and parameters at the end of optimization
%   - all the variables that are not affected by the optimized parameters
%   should be on 1:1 line
%   - water cycle variables should divert from 1:1 line (e.g., ET, wTotal)

%% clean the path and memory
try
    gone
    for fn              =	{'tools','model','optimization','testBeds'}
        rmpath(genpath(['../../' fn{1}]))
    end
catch
end

%% add the paths of the necessary sindbad directories

for fn                  =	{'tools','model','optimization','testBeds'}
    addpath(genpath(['../' fn{1}]),'-begin')
end


%% set the paths of input and output directory for the tests
% the path for the input and output as empty
% default input path is used (runs in cluster): /Net/Groups/BGI/work_3/sindbad/data/testBeds/input/
% default output path is used (runs in cluster):
% /Net/Groups/BGI/work_3/sindbad/data/testBeds/output/$userName
userInPath              =   '';
userOutPath             =   '';

% Alternatively set the path for the input and output (for local runs)
% copy the test input: /Net/Groups/BGI/work_3/sindbad/data/testBeds/input/
% to a local directory. NEVER COPY IT TO SINDBAD ROOT
% set the userOutPath to save the output to any directory. In this case
% $username is not appended to the path. NEVER SET IT INSIDE SINDBAD ROOT


% %Tina
userInPath              =   'C:/Users/ttraut/Documents/SindbadTestData/input/';
userOutPath             =   'C:/Users/ttraut/Documents/SindbadTestData/output/';


if isempty(userInPath)
    inDir               =   '/Net/Groups/BGI/work_3/sindbad/data/testBeds/input/';
else
    inDir               =   userInPath;
end

if isempty(userOutPath)
    outDir              =   'C:\Users\ttraut\Desktop\sindbad tests'%'/Net/Groups/BGI/work_3/sindbad/data/testBeds/output/';
    [uname,~]           =	getUserInfo();
    outDir              =   [outDir '/' uname];
else
    outDir              =   userOutPath;
end

%% select the tests to run (see explanations at the beginning of this script)
% testCases               =   [1 2 3 4 5];
% testCases               =   [5];
% testCases               =   [4];
% testCases             =   [ 5 ];
% testCases             =   [ 1 3 4 ];
testCases               =   [ 3 4 5];

%% run the different tests
for i                   =   testCases
    switch i
        case 1
            inpath      =   [inDir '/' 'NH_25.mat'];
            obspath     =   '';
            testName    =   'cCycleSpinup';
        case 2
            inpath      =   [inDir '/' 'US-Ha1.2000-2015.nc'];
            obspath     =   inpath;
            testName    =   'cCycleOpti';
        case 3
            inpath      =   [inDir '/' 'globalTWS_Forcing.mat'];
            obspath     =   '';
            testName    =   'wCycleForward';
        case 4
            inpath      =   [inDir '/' 'globalTWS_Forcing.mat'];
            obspath     =   [inDir '/' 'globalBaseline_Constraints_1deg.mat'];
            testName    =   'wCycleOpti';
        case 5
            inpath      =   [inDir '/' 'US-Ha1.2000-2015.nc'];
            obspath     =   '';
            testName    =   'cLAISpinup';
            
            
    end
    evalStr             =   ['test_' testName '(''' char(inpath) ''',''' char(outDir) ''',''' obspath ''',''' char(testName) ''');'];
    eval(evalStr);
    
end

