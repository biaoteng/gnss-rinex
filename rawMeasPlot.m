function rawMeasPlot(obs, observables, Path)
%% define observables
% startGPSTime = 345721; % 2018-06-21 00:02:01
startGPSTime = 367321; % 2018-06-21 06:02:01
tow = obs(:,2);
prn = obs(:,4);
for i = 1 : length(obs)
    switch round(prn(i)/1000)
        case 1
    %         SatSys = 'GPS';
            obs_gps = obs(round(prn/1000) == 1,:);
            prn_gps = obs_gps(:,4);
        case 4
    %         SatSys = 'Galileo'
            obs_galileo = obs(round(prn/1000) == 4,:);
            prn_galileo = obs_galileo(:,4);
           
        otherwise 
            error 'Unsupprted constellation' 
    end
end

gps_freq_var = {'L1CA', 'L2C'};
galileo_freq_var = {'E1','E5b'};

% distinguish prn
prn_list = unique(prn);
prn_list_gps = prn_list(prn_list < 4000);
prn_list_galileo = prn_list(prn_list > 4000);

%%  observables: {'SNR', 'pseudorange', 'carrier', 'doppler', 'cmc' }
switch observables
    case {'SNR', 'pseudorange', 'carrier', 'doppler' }
        switch observables
            case 'SNR'
                unit = '[dBHz]';
                lim = [20,60];
                rawMeas1 = obs_gps(:,8);
                rawMeas2 = obs_gps(:,12);
                rawMeas3 = obs_galileo(:,8);
                rawMeas4 = obs_galileo(:,12);
            case 'pseudorange'
                unit = '[m]';
                rawMeas1 = obs_gps(:,5);
                rawMeas2 = obs_gps(:,9);
                rawMeas3 = obs_galileo(:,5);
                rawMeas4 = obs_galileo(:,9);
            case 'carrier'
                unit = '[cycles]';
                rawMeas1 = obs_gps(:,6);
                rawMeas2 = obs_gps(:,10);
                rawMeas3 = obs_galileo(:,6);
                rawMeas4 = obs_galileo(:,10);
            case 'doppler'
                unit = '[Hz]';
                rawMeas1 = obs_gps(:,7);
                rawMeas2 = obs_gps(:,11);
                rawMeas3 = obs_galileo(:,7);
                rawMeas4 = obs_galileo(:,11);       
        end
        rawMeas_gps = [rawMeas1, rawMeas2];
        rawMeas_galileo = [rawMeas3, rawMeas4];
        plotName = observables;
        dir = fullfile(Path, plotName);
        mkdir(dir);
        fileID = fopen(fullfile(dir,'stats.txt'),'w+'); % write stats into txt file
        fprintf(fileID,'%4s %20s %20s\r\n','PRN', 'mean','std'); % header
        for i = 1:length(prn_list)
            switch round(prn_list(i)/1000)
                case 1 
                    SatSys = 'GPS';
                    for j = 1 : length(gps_freq_var) 
                        prn_num = num2str(prn_list(i));
                        rawMeas = rawMeas_gps(:,j);
                        x = tow(prn==prn_list(i));
                        y = rawMeas(prn_gps==prn_list(i));
                        x = x - startGPSTime;
                        figure()
                        plot(x, y, 'r','Marker','.');
                        if exist('lim')
                            ylim(lim)
                        end
                        grid on
                        xlim([0 450])
                        xlabel('time[s]')
                        ylabel([observables,unit])
                        legend(['PRN ', prn_num(3:4),' ', SatSys, gps_freq_var{j}])
                        thisImage = ['PRN', prn_num(3:4), '_',gps_freq_var{j},'_', plotName, '.png'];
                        fullDir = fullfile(dir, thisImage);
                        saveas(gcf, fullDir);
                        mean_wMP = mean(y(~isnan(y)));
                        std_wMP = std(y(~isnan(y)));
                        fprintf(fileID,'%2s %4s %20.8f %20.8f\r\n', prn_num(3:4), gps_freq_var{j},mean_wMP, std_wMP);
                    end
                case 4
                    SatSys = 'Galileo';
                    for j = 1 : length(galileo_freq_var) 
                        prn_num = num2str(prn_list(i));
                        rawMeas = rawMeas_galileo(:,j);
                        x = tow(prn==prn_list(i));
                        y = rawMeas(prn_galileo==prn_list(i));
                        x = x - startGPSTime;
                        figure()
                        plot(x, y, 'r','Marker','.');
                        if exist('lim')
                            ylim(lim)
                        end
                        grid on
                        xlim([0 450])
                        xlabel('time[s]')
                        ylabel([observables,unit])
                        legend(['PRN ', prn_num(3:4),' ',SatSys, galileo_freq_var{j}])
                        thisImage = ['PRN', prn_num(3:4), '_',galileo_freq_var{j},'_' plotName, '.png'];
                        fullDir = fullfile(dir, thisImage);
                        saveas(gcf, fullDir);
                        mean_wMP = mean(y(~isnan(y)));
                        std_wMP = std(y(~isnan(y)));
                        fprintf(fileID,'%2s %4s %20.8f %20.8f\r\n', prn_num(3:4),galileo_freq_var{j}, mean_wMP, std_wMP);
                    end
            end
                    
        end
        fclose(fileID);
    
    
    case {'cmc'}
        cmc_var = {'cmc L1CA','cmc L2C','cmc E1','cmc E5b'};
        c  = 299792458;
        f_L1CA = 1575.42e6;
        f_L2C = 1227.60e6;
        f_E1 = 1575.42e6;
        f_E5b = 1207.14e6;
%         lambda_L1CA = c/f_L1CA;
%         lambda_L2C = c/f_L2C;
%         lambda_E1 = c/f_E1;
%         lambda_E5b = c/f_E5b;
        for j = 1: length(cmc_var)
            observables_detailed = cmc_var{j};
            switch observables_detailed
                case 'cmc L1CA'
                    f = f_L1CA;
                    code = obs_gps(:,5);
                    carrier = obs_gps(:,6);
                    SatSys = 'GPS ';
                case 'cmc L2C'
                    f = f_L2C;
                    code = obs_gps(:,9);
                    carrier = obs_gps(:,10);
                    SatSys = 'GPS ';
                case 'cmc E1'
                    f = f_E1;
                    code = obs_galileo(:,5);
                    carrier = obs_galileo(:,6);
                    SatSys = 'Galileo ';
                case 'cmc E5b'
                    f = f_E5b;
                    code = obs_galileo(:,9);
                    carrier = obs_galileo(:,10);
                    SatSys = 'Galileo ';
            end
            cmc = code - carrier * c / f; % problem: 0!? missing carrier phase measurements?
            cmc(cmc==0) = nan;
            cmc(abs(cmc) > 10) = nan;
            plotName = observables_detailed;
            dir = fullfile(Path, plotName);
            mkdir(dir);
            fileID = fopen(fullfile(dir,'stats.txt'),'w+'); % write stats into txt file
            fprintf(fileID,'%4s %20s %20s\r\n','PRN', 'mean','std'); % header
            if strcmp(SatSys, 'GPS ')
                for i = 1:length(prn_list_gps)
                    prn_num = num2str(prn_list_gps(i));
                    x = tow(prn==prn_list_gps(i));
                    y = cmc(prn_gps==prn_list_gps(i));
                    if (sum(~isnan(y)) == 0)
                        % skip invalid cmc
                    else
                        % exlude initial ambiguity by subrtacting average
                        y_real = y(~isnan(y));
                        y_shifted = y - mean(y_real);

                        x = x - startGPSTime;
                        figure()
                        plot(x, y_shifted , 'r','Marker','.');
                        xlabel('time[s]')
                        ylabel([observables,'[m]'])
                        xlim([0 450])
                        grid on
        %                 ylim([-10 10])
                        legend(['PRN', prn_num(3:4),' ',SatSys,' ', plotName])
                        thisImage = ['PRN', prn_num(3:4), '_',SatSys, plotName, '.png'];
                        fullDir = fullfile(dir, thisImage);
                        saveas(gcf, fullDir);  
                        mean_wMP = mean(y_shifted);
                        std_wMP = std(y_shifted);
                        fprintf(fileID,'%2s %8s %20.8f %20.8f\r\n',prn_num(3:4), plotName, mean_wMP, std_wMP);
                    end
                end
            elseif strcmp(SatSys, 'Galileo ')
                for i = 1:length(prn_list_galileo)
%                   SatSys = 'Galileo';
                    prn_num = num2str(prn_list_galileo(i));
                    x = tow(prn==prn_list_galileo(i));
                    y = cmc(prn_galileo==prn_list_galileo(i));
                    if (sum(~isnan(y)) == 0)
                        % skip invalid cmc
                    else
                        % exlude initial ambiguity by subrtacting average
                        y_real = y(~isnan(y));
                        y_shifted = y - mean(y_real);

                        x = x - startGPSTime;
                        figure()
                        plot(x, y_shifted , 'r','Marker','.');
                        xlim([0 450])
                        xlabel('time[s]')
                        ylabel([observables,'[m]'])
                        grid on
        %                 ylim([-10 10])
                        legend(['PRN', prn_num(3:4),' ', SatSys,' ',plotName])
                        thisImage = ['PRN', prn_num(3:4), '_', SatSys, plotName, '.png'];
                        fullDir = fullfile(dir, thisImage);
                        saveas(gcf, fullDir);  
                        mean_wMP = mean(y_shifted);
                        std_wMP = std(y_shifted);
                        fprintf(fileID,'%2s %8s %20.8f %20.8f\r\n',prn_num(3:4), plotName, mean_wMP, std_wMP);
                    end
                    
                end
            end

        end
        
        
        fclose(fileID);
    otherwise
        disp('error: observable not found')
end

end 

