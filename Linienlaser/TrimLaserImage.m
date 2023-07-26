function [data, idxLeft, idxRight] = trimLaserImage(data, fileName, maxThresh)

height = size(data,1);
width = size(data,2);
halfWidth = round(width/2);

if length(maxThresh) == 2  % known trim interval
    idxLeft = maxThresh(1);
    idxRight = maxThresh(2);

elseif maxThresh == -1  % manual clicking of trim intervals
    figure;
    screenSize = get(0, 'ScreenSize');
    set(gcf, 'Position', screenSize);
    imshow(data)
    click = winput(1);
    idxLeft = round(click(1));
        
    click = winput(1);
    idxRight = round(click(1));   
    close(gcf);
    

else  % auto maximum trim intervals
    if contains(fileName, "_R.")  % right flank
        rowIdx = 1;  % take top row
    else  % left flank
        rowIdx = height;  % take bottom row
    end
    
    % Current row
    row = data(rowIdx,:);
    
    % Threshold depends on maximum value of row
    maxVal = maxThresh * max(row);
    
    % Go from row center backwards to find left flank
    idxLeft = find(row(1:halfWidth) >= maxVal, 1, 'last');
    
    % Go from row center forward to find right flank
    idxRight = halfWidth + find(row(halfWidth+1:width) >= maxVal, 1, 'first');
end

fprintf("Left margin: %d of %d\n", idxLeft, width);
fprintf("Right margin: %d of %d\n", idxRight, width);
    
% Trim data to new interval
data = data(:,idxLeft:idxRight);