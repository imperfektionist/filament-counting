function data = detrend2D(data, cellSizeVert, plotFilterMask, filePath)

wb = waitbar(0, "Detrending...");

envelope = NaN(size(data));

stretchFactor = 1;  % cell width to cell height ratio
thresh = -5;

height = size(data,1);
width = size(data,2);

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

        roi = data(u_up:u_down,v_left:v_right);
        roi = roi(roi > thresh);

        envelope(u_up:u_down,v_left:v_right) = median((roi),"all");
%         maxi = max(roi(:));
%         if ~isnan(maxi)
%             envelope(u_up:u_down,v_left:v_right) = maxi;
%         end
    end
    waitbar(y/height, wb, sprintf("Detrending %d%%", round(y/height*100)));
end

outputFileName = strrep(filePath,".csv","_mask.png");
imwrite(data, outputFileName);
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
data = data - envelope;

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

