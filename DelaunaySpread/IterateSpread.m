function [xy_synth, DT_synth, EL_synth] = IterateSpread(xy_synth, EL_true, par)

    m = median(EL_true);
    hist_true = HistogramCurve(EL_true, par.binWidth);
    num_bins = length(hist_true.centers);
    EL_min = hist_true.centers(1);
    EL_max = hist_true.centers(end);
    
    % No iterations
    if par.num_iters == 0
        [DT_synth, EL_synth] = DelaunayTriangulation(xy_synth, [0, 10]);
    end
    
    % Iterative algorithm with decreasing step width 1/i
    for iter = 1:par.num_iters
    
        fprintf("Iteration: %d/%d\n", iter, par.num_iters)
    
        [DT_synth, EL_synth] = DelaunayTriangulation(xy_synth, [0, 10]);
        hist_synth = HistogramCurve(EL_synth, hist_true.edges);
    
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
    
                %idx = LinearMap(d, EL_min, EL_max, 1, num_bins);
                %err = abs(hist_true.counts(idx) - hist_synth.counts(idx))^2;
    
                xy_next(p,:) = xy_next(p,:) + s / iter;  % absolute shift
                %xy_next(p,:) = xy_next(p,:) + s * err * 1;  % absolute shift
            end
        end
        xy_synth = xy_next;    
    end
end

% Map linear x to linear y by specifying two fixed points each
function y = LinearMap(x, xmin, xmax, ymin, ymax)
    y = round((ymax-ymin) * (x-xmin) / (xmax-xmin) + ymin);
    if y < ymin  % clamp low
        y = ymin;
    elseif y > ymax  % clamp high
        y = ymax;
    end
end