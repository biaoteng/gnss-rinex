function [] = trackPlotter(Path,file, graphType, lineWidth, markerSize, color, gaps)

refLat = 0;
refLon = 0;
refAlt = 0;
% fig = figure();
%% count headerlines
idFile  = fopen ([Path file]);
headerlines = 0;
while (true)
    line = fgetl(idFile);
    if ( line(1) == '%')
        headerlines = headerlines + 1;
    else
        break
    end
end
%%
posData = importdata([Path file], ' ', headerlines);
if isfield(posData, 'data')
[x,y,z] = lla2ecef(deg2rad(posData.data(:,1)), deg2rad(posData.data(:,2)),posData.data(:,3));
[x_ref,y_ref,z_ref] = lla2ecef(refLon, refLat,refAlt);
% x = posData.data(:,2);
% y = posData.data(:,1);
timeStr = posData.textdata(headerlines + 1 : end, 2);
timeNum = datenum(timeStr, 'HH:MM:SS.FFF');
satNum = posData.data(:,5);

% valid = abs(x) < 100000 & abs(y) < 100000;
% x(~valid) = NaN;
% y(~valid) = NaN;

if strcmp(color, 'color') == false
    plot(x - x_ref, y - y_ref, graphType, 'LineWidth', lineWidth, 'Markersize', markerSize, 'Color', [0.5 0.5 0.5],'MarkerEdgeColor', color);
end

if strcmp(color, 'color') == true
    uniqueS = unique(satNum); % exclude satNum = 0 Edit: not suitable for M8L, which is equipped with IMU
                              % uniqueS = unique(satNum(satNum ~= 0));
    uniqueS = uniqueS(~isnan(uniqueS)); % exclude satNum = nan
    cmatrix = flipud(jet(26));
    l = zeros(length(uniqueS));
    
    hold on
    for i = 1 : length(uniqueS)
        idx = satNum == uniqueS(i);
        if uniqueS(i) == 0
            uniqueS(i) = 1;
        end
        l(i) = plot(x(idx), y(idx), '*', 'Markersize', markerSize, 'Color', cmatrix(uniqueS(i),:));
        legend(l(1:i), num2str(uniqueS(1:i)));
    end
end

if gaps == true
    hold on;
    timeSec = rem(timeNum,1) * 24 * 60 * 60;
    for i = 2 : 1 : length(timeNum) 
        if timeSec(i) - timeSec(i - 1) > 0.15 
            plot([x(i - 1); x(i)], [y(i - 1); y(i)], graphType, 'LineWidth', lineWidth, 'Markersize', markerSize , 'Color', 'k');
        end
    end
end

hold on



% [refX, refY] = lla2ecef(deg2rad(refLat), deg2rad(refLon));
plot( 0,0,'-p','MarkerFaceColor','blue','MarkerSize',15, 'Color', 'k');
% plot([refLon, refLon], [min(x), max(x)],'Color', [0.7 0.7 0.7]);
% plot([min(y), max(y)], [refLat, refLat],'Color', [0.7 0.7 0.7]);
xlabel('ECEF X relative coordinate[m]');
ylabel('ECEF Y relative coordinate[m]');
axis equal


temp_name = strsplit(file, '.');
plotName = temp_name{1};

thisImage = [ plotName  '.png'];
fullDir = fullfile(Path, thisImage);
saveas(gcf, fullDir);
% customize data cursor
% dcm_obj = datacursormode(fig);
% set(dcm_obj, 'UpdateFcn', {@myupdatefcn_groundtrack, timeNum, satNum});
else disp('Error: No positions')
end
end