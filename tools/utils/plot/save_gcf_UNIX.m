function save_gcf_UNIX(cf, fn, closefig, justpng, fileID)

if ~exist('closefig', 'var')
    closefig = 1;
end
if ~exist('justpng', 'var')
    justpng = 0;
end
if ~exist('fileID', 'var')
    fileID = 0;
end

% suddenly we need this... weird...
if isunix
    try
    if ~exist('/scratch/tmp','dir')
        mkdirx('/scratch/tmp');
    end
    catch
        disp('Non-Critical: redundant directory for unix was not created in save_gcf_unix')
    end
end

% plot to EPS
pmode = get(cf,'PaperPositionMode');
units = get(cf,'PaperUnits');
pos   = get(cf,'PaperPosition');
try
    if exist([fn '.eps'],'file')
        delete([fn '.eps']);
    end
    set(cf,'PaperPositionMode', 'manual');
    set(cf,'PaperUnits', 'normalized');
    set(cf,'PaperPosition', [0,0,1,1]);
    print(cf, [fn '.eps'], '-depsc', '-r300', '-noui', '-painters');
    set(cf,'PaperPositionMode', pmode);
    set(cf,'PaperUnits', units);
    set(cf,'PaperPosition', pos);
    if ~justpng&&fileID>0;try dispJ(['saved : ' fn '.eps'], fileID);catch end
    end
catch
    if fileID>0;try dispJ(['no way: ' fn '.eps'], fileID);catch end
    end
    set(cf,'PaperPositionMode', pmode);
    set(cf,'PaperUnits', units);
    set(cf,'PaperPosition', pos);
end

% convert to PNG
try
    if exist([fn '.png'],'file')
        delete([fn '.png']);
    end
    if ispc % Use Windows ghostscript call
        cmd = 'gswin64c';
    else % Use Unix/OSX ghostscript call
        cmd = 'gs';
    end
    system([cmd ' -q -dSAFER -sDEVICE=png16m -dNOINTERPOLATE -dEPSCrop -r300 -o %stdout ' fn '.eps | convert -resize 25% - ' fn '.png']);
    if justpng
        delete([fn '.eps']);
    end
    if fileID>0;try dispJ(['saved : ' fn '.png'], fileID);catch end
    end
catch
    if fileID>0;try dispJ(['no way: ' fn '.png'], fileID);catch disp(['no way: ' fn '.png']);end
    end
end

% save the matlab figure
if justpng == -1
    if exist([fn '.fig'],'file')
        delete([fn '.fig']);
    end
    saveas(cf, [fn '.fig']);
    if fileID>0;try dispJ(['saved : ' fn '.fig'], fileID);catch end
    end
end

if closefig
    close(cf)
end
