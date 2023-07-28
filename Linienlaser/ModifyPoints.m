% clear

inPath = 'UserData/BU2281_WSS_2U_L_hough.png';
image = imread(inPath);

deleteFirst = 1;  % click once for delete, twice for add
aspect = 2560/1440;
markerSize = 20;
lw = 3;  % lineWidth

delFile = strrep(inPath, ".png", "_delPoints.txt");
addFile = strrep(inPath, ".png", "_addPoints.txt");

% Insert deleted (and added) points if a file already exists
if exist(delFile, "file")
    if deleteFirst            
        total_1st = readmatrix(delFile);
        total_2nd = readmatrix(addFile);
        for i = 1:size(total_1st,1)
            image = insertMarker(image, total_1st(i,:), 'x', 'Color', 'cyan', "Size", markerSize);            
        end
        for i = 1:size(total_2nd,1)
            image = insertMarker(image, total_2nd(i,:), '+', 'Color', 'cyan', "Size", markerSize);
        end
    else  % add first
        total_1st = readmatrix(addFile);
        total_2nd = readmatrix(delFile);
        for i = 1:size(total_1st,1)
            image = insertMarker(image, total_1st(i,:), '+', 'Color', 'cyan', "Size", markerSize);            
        end
        for i = 1:size(total_2nd,1)
            image = insertMarker(image, total_2nd(i,:), 'x', 'Color', 'cyan', "Size", markerSize);
        end
    end
else
    total_1st = [];
    total_2nd = [];
end

% plot(xy_1st(:,1), xy_1st(:,2),  "g.", "Marker", "x", "MarkerSize", markerSize, "LineWidth", lw);
% plot(xy_2nd(:,1), xy_2nd(:,2), "g.", "Marker", "+", "MarkerSize", markerSize, "LineWidth", lw);
% 
% plot(xy_1st(:,1), xy_1st(:,2),  "g.", "Marker", "+", "MarkerSize", markerSize, "LineWidth", lw);
% plot(xy_2nd(:,1), xy_2nd(:,2), "g.", "Marker", "x", "MarkerSize", markerSize, "LineWidth", lw);

height = size(image,1);
width = size(image,2);

singleWidth = round(height * aspect);

% figure('units','normalized','outerposition',[0 0 1 1])
figure;

i = 1;
% for i = 1:singleWidth:width
next_cycle = 1;
while next_cycle

    fprintf("Frame %d of %d\n",i,width);

    i_end = i + singleWidth - 1;
    
    if i_end > width  % superseded end
        i_end = width;  % cut to end
        next_cycle = 0;  % last iteration
    end

    subImage = image(:,i:i_end,:);

    xy_1st = NaN(2000,2);
    xy_2nd = NaN(2000,2);
    i_2nd = 1; i_1st = 1;
    
    click = [0, 0];
    imageShift = [i-1, 0];    

    hold off
    imshow(subImage)

    while true        

        click = winput(1);
        
        if isempty(click)
            % Store points for current subimage
            rows = any(isnan(xy_2nd),2);
            xy_2nd = xy_2nd(~rows, :) + imageShift;
            total_2nd = vertcat(total_2nd, xy_2nd);

            rows = any(isnan(xy_1st),2);
            xy_1st = xy_1st(~rows, :) + imageShift;
            total_1st = vertcat(total_1st, xy_1st); %#ok<*AGROW> 

            break;
        else
            fprintf("X: %.0f, Y: %.0f\n",click(1), click(2))
        end

        if i_1st > 1
            duplicate = norm(xy_1st(i_1st-1,:) - click) < 20;
        else
            duplicate = false;
        end

        if duplicate
            xy_1st(i_1st-1,:) = NaN(1,2);
            i_1st = i_1st - 1;

            xy_2nd(i_2nd,:) = click;
            i_2nd = i_2nd + 1;
        else    
            xy_1st(i_1st,:) = click;
            i_1st = i_1st + 1;
        end

        hold off
        imshow(subImage)
        hold on

        if deleteFirst            
            plot(xy_1st(:,1), xy_1st(:,2),  "g.", "Marker", "x", "MarkerSize", 20, "LineWidth", 3);
            plot(xy_2nd(:,1), xy_2nd(:,2), "g.", "Marker", "+", "MarkerSize", 20, "LineWidth", 3);
        else  % add first
            plot(xy_1st(:,1), xy_1st(:,2),  "g.", "Marker", "+", "MarkerSize", 20, "LineWidth", 3);
            plot(xy_2nd(:,1), xy_2nd(:,2), "g.", "Marker", "x", "MarkerSize", 20, "LineWidth", 3);
        end
        drawnow;
    end

    i = i + singleWidth;  % next start index
end

if deleteFirst            
    writematrix(total_1st, delFile);
    writematrix(total_2nd, addFile);
else  % add first
    writematrix(total_1st, addFile);
    writematrix(total_2nd, delFile);
    
end

disp("All done.")

close all
