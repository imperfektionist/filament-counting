clear

inPath = 'UserData/BU2281_WSS_2U_L_hough.png';
image = imread(inPath);

aspect = 2560/1440;

height = size(image,1);
width = size(image,2);

singleWidth = round(height * aspect);

% figure('units','normalized','outerposition',[0 0 1 1])
figure;

total_add = [];
total_del = [];

for i = 1:singleWidth:width

    if i+singleWidth > width
        break;
    end
    subImage = image(:,i:i+singleWidth-1,:);

    xy_add = NaN(1000,2);
    xy_del = NaN(1000,2);
    i_del = 1; i_add = 1;
    
    click = [0, 0];
    imageShift = [i-1, 0];    

    imshow(subImage)

    while true        

        click = winput(1);

        if isempty(click)
            % Store points for current subimage
            rows = any(isnan(xy_del),2);
            xy_del = xy_del(~rows, :) + imageShift;
            total_del = vertcat(total_del, xy_del);

            rows = any(isnan(xy_add),2);
            xy_add = xy_add(~rows, :) + imageShift;
            total_add = vertcat(total_add, xy_add); %#ok<*AGROW> 

            break;
        end

        if i_del > 1
            duplicate = norm(xy_del(i_del-1,:) - click) < 20;
        else
            duplicate = false;
        end

        if duplicate
            xy_del(i_del-1,:) = NaN(1,2);
            i_del = i_del - 1;

            xy_add(i_add,:) = click;
            i_add = i_add + 1;
        else    
            xy_del(i_del,:) = click;
            i_del = i_del + 1;
        end

        hold off
        imshow(subImage)
        hold on
        
        plot(xy_del(:,1), xy_del(:,2), "g.", "Marker", "x", "MarkerSize", 20, "LineWidth", 3);
        plot(xy_add(:,1), xy_add(:,2),  "b.", "Marker", "+", "MarkerSize", 20, "LineWidth", 3);
        drawnow;
    end
end

delFile = strrep(inPath, ".png", "_delPoints.txt");
addFile = strrep(inPath, ".png", "_addPoints.txt");

writematrix(total_del, delFile);
writematrix(total_add, addFile);

close all
