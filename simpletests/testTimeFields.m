% test structure access time
S               = zeros(100,3652);
poolname        = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
startvalues     = repmat({S},1,numel(poolname));
fx.ECO.efflux	= struct('value', startvalues);
fx.ECO.cOUT     = struct('value', startvalues);
fx2.efflux     = struct('value', startvalues);
fx2.cOUT     = struct('value', startvalues);

%% nested versus non nested: 10% in non nested
N=100;
tic
for i = 1:N
    for j = 1:numel(poolname)
        for k = 1:3652
            fx.ECO.efflux(j).value(:,k) = rand(100,1);
        end
    end
end
disp(['nested : not : ' num2str(toc) ' secs'])
tic
for i = 1:N
    for j = 1:numel(poolname)
        for k = 1:3652
            fx2.efflux(j).value(:,k) = rand(100,1);
        end
    end
end
disp(['nested : yes : ' num2str(toc) ' secs'])
%% single versus multiple index fields : longer
fx.ECO.efflux	= struct('ROOT', S, 'ROOTC', S, 'WOOD', S, 'LEAF', S, 'M_LEAF', S, 'S_LEAF', S, 'M_ROOT', S, 'S_ROOT', S, 'LiWOOD', S, 'LiROOT', S, 'LEAF_MIC', S, 'SOIL_MIC', S, 'SLOW', S, 'OLD', S);
N=100;
tic
for i = 1:N
    for j = 1:numel(poolname)
        for k = 1:3652
            fx.ECO.efflux.(poolname{j})(:,k) = rand(100,1);
        end
    end
end
disp(['dynamic fields : ' num2str(toc) ' secs'])
%% field versus variable
fx3.efflux = NaN([size(S) numel(poolname)]);
N=100;
tic
for i = 1:N
    for j = 1:numel(poolname)
        for k = 1:3652
            fx3.efflux(:,k,j) = rand(100,1);
        end
    end
end
disp(['field : 3D : yes : ' num2str(toc) ' secs'])

fx3_efflux = NaN([size(S) numel(poolname)]);
N=100;
tic
for i = 1:N
    for j = 1:numel(poolname)
        for k = 1:3652
            fx3_efflux(:,k,j) = rand(100,1);
        end
    end
end
disp(['matrix : 3D : yes : ' num2str(toc) ' secs'])
%% 3d cube versus individual fields
for hh = 1:10
S               = zeros(100,3652);
poolname        = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
startvalues     = repmat({S},1,numel(poolname));
fx.ECO.efflux	= struct('value', startvalues);
fx3.ECO.efflux = NaN([size(S) numel(poolname)]);
N=10;
tic
for i = 1:N
    for j = 1:numel(poolname)
        for k = 1:3652
            fx3.ECO.efflux(:,k,j) = rand(100,1);
        end
    end
end
disp(['field : 3D : yes : ' num2str(toc) ' secs'])

tic
for i = 1:N
    for j = 1:numel(poolname)
        for k = 1:3652
            fx.ECO.efflux(j).value(:,k) = rand(100,1);
        end
    end
end
disp(['field : 3D : no : ' num2str(toc) ' secs'])
end