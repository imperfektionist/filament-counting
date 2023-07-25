function data = detrend3(data, cellSizeVert, plotFilterMask, filePath)

wb = waitbar(0, "Detrending...");

envelope = zeros(size(data));

step = 100;
degree = 2;

height = size(data,1);
width = size(data,2);

% Detrend
for y = 1:height
    x = 1:step:width;

    medians = zeros(1,width);
    for i = 2:length(x)
        medians(x(i-1):x(i)) = median(data(y, x(i-1):x(i)));
    end
%     envelope(y,:) = medians;

    coefficients = polyfit(x, medians(x), degree);    
    envelope(y,:) = polyval(coefficients, 1:width);

    waitbar(y/height, wb, sprintf("Detrending %d%%", round(y/height*100)));
end

outputFileName = strrep(filePath,".csv","_mask.png");
imwrite(data, outputFileName);
% if plotFilterMask    
%     winopen(outputFileName);    
% end

outputFileName = strrep(filePath,".csv","_mask_avg.png");
imwrite(envelope, outputFileName);
if plotFilterMask    
    winopen(outputFileName);    
end

close(wb)

% % Decrease size to one pixel per cell, then increase bilinearly
% % This smoothes the gridified median cells
% small_size = [round(height/cellSizeVert) round(width/cellSizeHorz)];
% envelope = imresize(envelope,small_size,'method','box');
% envelope = imresize(envelope,size(data),'method','bilinear');
% 
% outputFileName = strrep(filePath,".csv","_mask_bilinear.png");
% imwrite(envelope, outputFileName);
% if plotFilterMask    
%     winopen(outputFileName);
% end

% Subtracting median cells from data to detrend
data = data - envelope;

outputFileName = strrep(filePath,".csv","_mask_data.png");
imwrite(data, outputFileName);
% if plotFilterMask    
%     winopen(outputFileName);
% end

end

function val = Clamp(val, a, b)
    if val < a
        val = a;
    elseif val > b
        val = b;
    end
end

