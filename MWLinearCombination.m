function MWLinearCombination( obs, Path )
% LINEARCOMBINATION includes Melbourne Wuebbena combination
% INPUT: obs matrix including 
% 1. GPS week 
% 2. time of week [s]
% 3. flag
% 4. prn 
% 5 - 8 C1C L1C D1C S1C
% 9 - 12 C2L L2L D2L S2L
% [pr1, ph1, dop1, pr2, ph2, dop2, snr]
plotName = 'MW';
dir = fullfile(Path, plotName);
mkdir(dir);
fileID = fopen(fullfile(dir,'stats.txt'),'w'); % write stats into txt file
fprintf(fileID,'%4s %12s %12s\r\n','PRN', 'MW_mean','MW_std'); % header
tow = obs(:,2);
prn = obs(:,4);
prn_list = unique(prn);

    % prn 10XX: GPS satellites
    % prn 20XX: Glonass satellites
    % prn 40XX: Galileo satellites
    % prn 50XX: Beidou satellites
prn_list = prn_list(prn_list < 2000); 
for i = 1:length(prn_list)
    gps_idx = (prn == prn_list(i)); % plot GPS
    if (sum(gps_idx) ~= 0)
        pr1 = obs(gps_idx,5); ph1 = obs(gps_idx,6); 
        pr2 = obs(gps_idx,9); ph2 = obs(gps_idx,10); 

        f1 = 1575420000; % [1/s]
        f2 = 1227600000; % [1/s] % L2
        c = 299792458;
        lambda1 = c/f1;
        lambda2 = c/f2;

        %GPS carriers frequencies MUST BE DONE LIKE WITH LAMBDA
        aNL = f1/(f1+f2);
        bNL = f2/(f1+f2);
        aWL = f1/(f1-f2);
        bWL = f2/(f1-f2);

        prNL = aNL*pr1 + bNL*pr2 ;
        phWL = aWL*ph1*lambda1 - bWL*ph2*lambda2 ;


        MW = phWL - prNL;

        if (sum(~isnan(MW)) == 0)
            % skip invalid MW obs
        else
            MW_real = MW(~isnan(MW));
            MW_exclude_ambguity = MW - MW_real(1);
            MW_exclude_ambguity(abs(MW_exclude_ambguity) > 100) = NaN;

            % MW_std = MW_Slip_Detector(MW);
            time = tow(gps_idx);
            time = time - time(1);
            figure()
            plot(time,MW_exclude_ambguity);
            xlabel('time[s]')
            ylabel('MW[m]')
            legend(['PRN', num2str(prn_list(i)), ' MW combination'])
            disp(['PRN', num2str(prn_list(i))])
            thisImage = ['PRN', num2str(prn_list(i)), '_', plotName, '.png'];
            fullDir = fullfile(dir, thisImage);
            saveas(gcf, fullDir); 
            MW_mean = mean(MW_exclude_ambguity(~isnan(MW_exclude_ambguity)));
            MW_std = std(MW_exclude_ambguity(~isnan(MW_exclude_ambguity)));
            fprintf(fileID,'%4s %12.8f %12.8f\r\n',num2str(prn_list(i)), MW_mean, MW_std);
        end
    end 
end
fclose(fileID);
end

