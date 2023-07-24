clear

inPath = 'UserData/BU2281_WSS_2U_R_hough.png';
image = imread(inPath);

aspect = 2560/1440;

height = size(image,1);
width = size(image,2);

singleWidth = round(height * aspect);

% figure('units','normalized','outerposition',[0 0 1 1])
figure;

xy_add = NaN(10000,2);
xy_del = NaN(10000,2);
i_del = 1; i_add = 1;

for i = 1:singleWidth:width

    i_del_first = i_del;
    i_add_first = i_add;

    if i+singleWidth > width
        break;
    end
    subImage = image(:,i:i+singleWidth-1,:);

    
    click = [0, 0];
    imageShift = [i-1, 0];    

    imshow(subImage)

    while true        

        click = winput(1);

        if isempty(click)
            break;
        end

        if i_del > 1
            duplicate = norm(xy_del(i_del-1,:) - click + imageShift) < 20;
        else
            duplicate = false;
        end

        if duplicate
            xy_del(i_del,:) = NaN(1,2);
            i_del = i_del - 1;

            xy_add(i_add,:) = click + imageShift;
            i_add = i_add + 1;
        else    
            xy_del(i_del,:) = click + imageShift;
            i_del = i_del + 1;
        end

        hold off
        imshow(subImage)
        hold on
        
        plot(xy_del(i_del_first:i_del,1) - imageShift, xy_del(i_del_first:i_del,2), ...
            "g.", "Marker", "x", "MarkerSize", 20, "LineWidth", 3);
        plot(xy_add(i_add_first:i_add,1) - imageShift, xy_add(i_add_first:i_add,2), ...
            "b.", "Marker", "+", "MarkerSize", 20, "LineWidth", 3);
        drawnow;
    end
end

xy_del = xy_del(1:i_del,:);
xy_add = xy_add(1:i_add,:);

delFile = strrep(inPath, ".png", "_delPoints.txt");
addFile = strrep(inPath, ".png", "_addPoints.txt");

writematrix(xy_del, delFile);
writematrix(xy_add, addFile);


