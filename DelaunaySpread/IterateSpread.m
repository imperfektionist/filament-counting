function [xy_synth, DT_synth, EL_synth] = IterateSpread(xy_synth, EL_true, par)

    EL_thresh_synth = [0, 5];  % allow broad range for first few iterations

    % Histogram of true edge lengths only calculated once    
    hist_true = HistogramCurve(EL_true, par.binWidth, par);
    num_bins = length(hist_true.centers);
    EL_min = hist_true.centers(1);  % shortest edge length
    EL_max = hist_true.centers(end);  % longest edge length
    m = median(EL_true);
    
    % Initial triangulation (also for zero iterations)
    [DT_synth, EL_synth] = DelaunayTriangulation(xy_synth, EL_thresh_synth);
    
    % Iterative algorithm with decreasing step width 1/i
    for iter = 1:par.num_iters

        % Histogram of synthetc edge lengths different every iteration
        hist_synth = HistogramCurve(EL_synth, hist_true.edges, par);

        % Output progress and current residue
        rsq = Rsquared(hist_true, hist_synth);
        fprintf("Iteration: %d/%d (R² = %.3f)\n", iter, par.num_iters, rsq)

        %fileID = fopen('rsq_opt.txt', 'a');
        %fprintf(fileID, '%f\n', rsq);
        %fclose(fileID);
    
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
                % Position vectors
                a = xy_synth(p,:);  % absolute center vector
                b = xy_synth(neighs(n),:);  % absolute neighbor vector
                c = b - a;  % relative vector
                d = norm(c);  % relative vector magnitude

                % Based on edge length median -> simple but inaccurate
                %s = c * (1 - m / d);  % shift vector
                %xy_next(p,:) = xy_next(p,:) + s / iter;  % absolute shift
    
                % Based on accummulated edge length histogram -> more accurate
                idx = LinearMap(d, EL_min, EL_max, 1, num_bins);  % bin number
                epsilon = hist_true.accum(idx) - hist_synth.accum(idx);  % residue
                s = c * (1 - m * (1 - epsilon) / d) / iter;  % shift vector
                xy_next(p,:) = xy_next(p,:) + s;  % absolute shift
            end
        end
        xy_synth = xy_next;

        [DT_synth, EL_synth] = DelaunayTriangulation(xy_synth, EL_thresh_synth);
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