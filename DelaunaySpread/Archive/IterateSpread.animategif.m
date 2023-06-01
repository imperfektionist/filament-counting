function [xy_synth, DT_synth, EL_synth] = IterateSpread(xy_synth, EL_true, num_iters)

m = median(EL_true);

% No iterations
if num_iters == 0
    [DT_synth, EL_synth] = DelaunayTriangulation(xy_synth, [0, 10]);
end

screen_size = get(0, 'ScreenSize');
figure('Position', [0 0 screen_size(3) screen_size(4)]);
aspect = screen_size(3) / screen_size(4);
x_median = median(xy_synth(:,1));
xlims = x_median + [-10 10] * aspect;
delayTime = 0.1;

anifile = fullfile('UserData', 'animation.gif');

% Iterative algorithm with decreasing step width 1/i
for iter = 1:num_iters

    [DT_synth, EL_synth] = DelaunayTriangulation(xy_synth, [0, 10]);

    triplot(DT_synth, xy_synth(:,1), xy_synth(:,2), 'k','LineWidth',2);
    ylim([-10 10])
    xlim(xlims)
    title(sprintf("Synthetic Distribution (Iteration: %d/%d)", iter, num_iters))
    drawnow;
    %pause(delayTime)
    frame = getframe(gcf);
    

    % Convert the frame to an indexed image
    im = im2gray(frame2im(frame));
    
    % Write the indexed image to the GIF file
    delayTime = 1 / iter;
    if iter == 1
        imwrite(im, anifile, 'gif', 'Loopcount', inf, 'DelayTime', delayTime);
    else
        imwrite(im, anifile, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
    end

    % Get neighbors of each point
    N = size(xy_synth, 1);
    neighbors = cell(N, 1);
    for d = 1:size(DT_synth, 1)        
        edges = nchoosek(DT_synth(d,:),2);
        for j = 1:3
            pt1 = edges(j, 1);
            pt2 = edges(j, 2);
            neighbors{pt1}(end+1) = pt2;
            neighbors{pt2}(end+1) = pt1;
        end
    end

    % Move each point towards equal spacing
    xy_next = xy_synth;
    for p = 1:N
        neighs = unique(neighbors{p});  % remove duplicates

        for n = 1:length(neighs)
            a = xy_synth(p,:);  % absolute center vector
            b = xy_synth(neighs(n),:);  % absolute neighbor vector
            c = b - a;  % relative vector
            d = norm(c);  % relative vector magnitude
            %s = c / d * (d - m)^2 * sign(d - m);  % shift vector
            s = c * (1 - m / d);  % shift vector
            xy_next(p,:) = xy_next(p,:) + s / iter;  % absolute shift
        end
    end
    xy_synth = xy_next;
    
end