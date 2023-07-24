function data = detrend2D(data, cellSizeVert, plotFilterMask, filePath)

wb = waitbar(0, "Detrending...");

envelope = zeros(size(data));

stretchFactor = 1;  % cell width to cell height ratio

height = size(data,1);
width = size(data,2);

data_fill = data;
% for x = 1:width
%     thresh = 50;
%     y = find(abs(data(2:height,x)-data(1:height-1,x)) > thresh, 1, "last");
%     data_fill(y:height,x) = 0.5;
%     waitbar(x/width, wb, sprintf("Filling %d%%", round(x/width*100)));
% end

% figure;
% surf(data, 'EdgeColor', 'none')
% colorbar;
% view(0, 90);

cellSizeHorz = round(cellSizeVert * stretchFactor);

% Calculate median for each cell
for y = 1:cellSizeVert:height
    u_up = Clamp(y - cellSizeVert, 1, height);
    u_down = Clamp(y + cellSizeVert, 1, height);

    for x = 1:cellSizeHorz:width
        v_left = Clamp(x - cellSizeHorz, 1, width);
        v_right = Clamp(x + cellSizeHorz, 1, width);

        envelope(u_up:u_down,v_left:v_right) = median(data_fill(u_up:u_down,v_left:v_right),"all");
    end
    waitbar(y/height, wb, sprintf("Detrending %d%%", round(y/height*100)));
end

outputFileName = strrep(filePath,".csv","_mask.png");
imwrite(data_fill, outputFileName);
if plotFilterMask    
    winopen(outputFileName);    
end

outputFileName = strrep(filePath,".csv","_mask_avg.png");
imwrite(envelope, outputFileName);
if plotFilterMask    
    winopen(outputFileName);    
end

close(wb)

% Decrease size to one pixel per cell, then increase bilinearly
% This smoothes the gridified median cells
small_size = [round(height/cellSizeVert) round(width/cellSizeHorz)];
envelope = imresize(envelope,small_size,'method','box');
envelope = imresize(envelope,size(data),'method','bilinear');

outputFileName = strrep(filePath,".csv","_mask_bilinear.png");
imwrite(envelope, outputFileName);
if plotFilterMask    
    winopen(outputFileName);
end

% Subtracting median cells from data to detrend
data = data_fill - envelope;

outputFileName = strrep(filePath,".csv","_mask_data.png");
imwrite(data, outputFileName);
if plotFilterMask    
    winopen(outputFileName);
end

end

function val = Clamp(val, a, b)
    if val < a
        val = a;
    elseif val > b
        val = b;
    end
end

