function save_gcf(cf, fn, closefig, justpng)
if ~exist('closefig', 'var'),    closefig    = 1; end
if ~exist('justpng', 'var'),    justpng     = 0; end
if ~justpng
    print(cf, [fn '.eps'], '-depsc')
end
if exist([fn '.png'],'file'),delete([fn '.png']),end

% computer name...
[ret, cname] = system('hostname');
if ret ~= 0
    if ispc
        cname = getenv('COMPUTERNAME');
    else
        cname = getenv('HOSTNAME');
    end
end

if isunix && ~ismac && ~strcmpi(deblank(cname),'etwa')
    save_gcf_UNIX(cf, fn, closefig, justpng)
    return
%     % suddenly we need this... weird...
%     if~exist('/scratch/tmp','dir'),mkdir('/scratch/tmp');end
%     if justpng == 1, justpng = -1; end
%     if justpng == -1
%         try
%             if exist([fn '.png'],'file'),delete([fn '.png']),end
%             print(cf, [fn '.png'], '-dpng', '-r600')
%             tmp = '.png';
%         catch
%             disp(['no way: ' fn '.png'])
%         end
%         if exist([fn '.fig'],'file'),delete([fn '.fig']),end
%         saveas(cf, [fn '.fig']);
%         tmp = '.fig';
%     else
%         if exist([fn '.png'],'file'),delete([fn '.png']),end
%         print(cf, [fn '.png'], '-dpng', '-r600')
%         tmp = '.png';
%     end
%     disp(['save end : ' fn tmp])
else
    if justpng == -1
        if exist([fn '.fig'],'file'),delete([fn '.fig']),end
        saveas(cf, [fn '.fig']);
        tmp = '.fig';
    else
        computer_name    = deblank(getenv('COMPUTERNAME'));
        if strcmpi(computer_name,'KERBALA') || ...
                isempty(computer_name) || ...
                strcmpi(computer_name,'DESNA') || ...
                strcmpi(computer_name,'BARRACUDA') || ...
                strcmpi(computer_name,'BARBUDA') || ...
                strcmpi(computer_name,'ANTIGUA')
            
            try
%                 saveas(cf, fn, 'png')
                print(cf, [fn '.png'], '-dpng', '-r300')
            catch
                try
                    print(cf, [fn '.png'], '-dpng', '-r400')
                catch
                    try
                        print(cf, [fn '.png'], '-dpng', '-r200')
                    catch
                        % it is not about memory!
                        % something to do with the file permissions...
                        disp(['could not print ' fn '.png'])
                    end
                end
            end
        else
            saveas(cf, fn, 'png')
%         img     = getframe(gcf);
%         
%         % Test built-in IMWRITE
%         tic;
%         imwrite(img.cdata,'example1.png');
        %             print(cf, [fn '.png'], '-dpng')
        end
    end
end
% if justpng == -1
%     try
%         if exist([fn '.fig'],'file'),delete([fn '.png']),end
%         saveas(cf, [fn '.fig']);
%     catch
%         disp(['MSH : save_gcf : could not save ' fn '.fig']);
%     end
% end
if closefig, close(cf), end
