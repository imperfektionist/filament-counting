function data = detrend2D(data, cellSize, plotFilterMask)

envelope = zeros(size(data));

height = size(data,1);
width = size(data,2);

wb = waitbar(0, "Detrending...");

for y = 1:cellSize:height
    u_up = Clamp(y - cellSize, 1, height);
    u_down = Clamp(y + cellSize, 1, height);

    for x = 1:cellSize:width
        v_left = Clamp(x - cellSize, 1, width);
        v_right = Clamp(x + cellSize, 1, width);

        envelope(u_up:u_down,v_left:v_right) = median(data(u_up:u_down,v_left:v_right),"all");

    end
    waitbar(y/height, wb, sprintf("Detrending %d%%", round(y/height*100)));
end

close(wb)
small_size = [round(size(data,1)/cellSize) round(size(data,2)/cellSize)];
envelope = imresize(envelope,small_size,'method','box');
envelope = imresize(envelope,size(data),'method','bilinear');

if plotFilterMask
    imwrite(envelope, "envelope.png");
    winopen("envelope.png");
end

function val = Clamp(val, a, b)
    if val < a
        val = a;
    elseif val > b
        val = b;
    end
end


data = data - envelope;

end

% tangential detrend direction == 1
% axial detrend direction == 2

% wb = waitbar(0, "Detrending...");
% 
% % Tangential detrend: cycle through rows
% if direction == "tang"
%     n = size(data,2);
%     y = zeros(1,n);
%     for i = 1:n
%         y(i) = median(data(:,i));
%         waitbar(i/n, wb, sprintf("Tangential detrend %d%%", round(i/n*100)));
%     end
%     
%     x = 1:n;
%     coefficients = polyfit(x, y, degree);
%     y = polyval(coefficients, x);
%     data = data - y;
% 
%     close(wb)
% 
% % Axial detrend: cycle through columns
% elseif direction == "ax"
%     n = size(data,1);
%     y = zeros(n,1);
%     for i = 1:n
%         y(i) = median(data(i,:));
%         waitbar(i/n, wb, sprintf("Axial detrend %d%%", round(i/n*100)));
%     end
% 
%     x = 1:n;
%     coefficients = polyfit(x, y, degree);
%     y = polyval(coefficients, x)';
%     data = data - y;
% 
%     close(wb)
% 
% else
%     disp("Wrong detrend direction.")
% end

