function data = lengthMask(data, par)

filePath = fullfile(par.userPath, par.csvFileName);

wb = waitbar(0, "Detrending...");
plotFilterMask = par.plotFilterMask;

envelope = NaN(size(data));

thresh = -5;

height = size(data,1);
width = size(data,2);

% figure;
% surf(data, 'EdgeColor', 'none')
% colorbar;
% view(0, 90);

cellSizeHorz = par.cellSizeTang;
cellSizeVert = par.cellSizeAx;

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

% outputFileName = strrep(filePath,".csv","_lengthmask.png");
% imwrite(data, outputFileName);
% if plotFilterMask    
%     winopen(outputFileName);    
% end

outputFileName = strrep(filePath,".csv","_lengthmask_avg.png");
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

outputFileName = strrep(filePath,".csv","_lengthmask_bilinear.png");
imwrite(envelope, outputFileName);
if plotFilterMask    
    winopen(outputFileName);
end

% env_tang = mean(envelope,1);
% env_ax = mean(envelope,2);
% env_tang = min(envelope,[],1);
% env_ax = min(envelope,[],2);
env_tang = max(envelope,[],1);
env_ax = max(envelope,[],2);

writematrix(env_tang, "eccentricity.txt")

% Subtracting median cells from data to detrend
data = data - envelope;

figure;
subplot(2,1,1)
plot(env_tang, 'k', 'LineWidth', 2)
subtitle('Tangential eccentricity')

subplot(2,1,2)
plot(env_ax, 'b', 'LineWidth', 2)
subtitle('Axial slope')


outputFileName = strrep(filePath,".csv","_lengthmask_data.png");
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

