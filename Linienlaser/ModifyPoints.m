% clear

inPath = 'UserData/BU6981_2U_L_hough.png';
image = imread(inPath);

deleteFirst = 0;  % click once for delete, twice for add
aspect = 2560/1440;

height = size(image,1);
width = size(image,2);

singleWidth = round(height * aspect);

% figure('units','normalized','outerposition',[0 0 1 1])
figure;

total_1st = [];
total_2nd = [];

for i = 1:singleWidth:width

    fprintf("Frame %d of %d\n",i,width);

    if i+singleWidth > width
        break;
    end
    subImage = image(:,i:i+singleWidth-1,:);

    xy_1st = NaN(2000,2);
    xy_2nd = NaN(2000,2);
    i_2nd = 1; i_1st = 1;
    
    click = [0, 0];
    imageShift = [i-1, 0];    

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
end

delFile = strrep(inPath, ".png", "_delPoints.txt");
addFile = strrep(inPath, ".png", "_addPoints.txt");

if deleteFirst            
    writematrix(total_1st, delFile);
    writematrix(total_2nd, addFile);
else  % add first
    writematrix(total_1st, addFile);
    writematrix(total_2nd, delFile);
    
end

disp("All done.")

close all
