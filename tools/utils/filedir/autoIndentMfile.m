function autoIndentMfile(mFile)
% auto indents the mfile contents if a full path to the mfile is provided
% mFile='/home/skoirala/sindbad/plg_gw/data/output//Site_Forward_FR-HES_20181119/code/genCore_Site_Forward_FR_HES_20181119.m'
theDocument = matlab.desktop.editor.openDocument(mFile);
smartIndentContents(theDocument);
save(theDocument);
close(theDocument);
end