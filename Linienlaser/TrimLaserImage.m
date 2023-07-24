function data = trimLaserImage(data, fileName, maxThresh)

height = size(data,1);
width = size(data,2);
halfWidth = round(width/2);

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
    
% Trim data to new interval
data = data(:,idxLeft:idxRight);