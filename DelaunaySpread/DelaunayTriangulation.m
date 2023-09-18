function [DT, edgeLengths, edgeAngles] = DelaunayTriangulation(xy, edgeThresh)

% Compute Delaunay triangulation
DT = delaunay(xy(:,1), xy(:,2));

% Pre-initialize edge lengths matrix
edgeLengths = zeros(size(DT,1)*3, 1);
edgeAngles = NaN(size(DT,1)*3, 1);
EL = cell(size(xy,1),1);
% PHI = cell(size(xy,1),1);

% Compute edge lengths
idx = 1;
for i = 1:size(DT,1)
    triangle = DT(i,:);
    edges = nchoosek(triangle,2);
    edgeLengths(idx:idx+2) = sqrt(sum((xy(edges(:,1),:) - xy(edges(:,2),:)).^2, 2));
    
%     % Calculate the angles of the triangle using atan2
%     dx = xy(edges(:, 2), 1) - xy(edges(:, 1), 1);
%     dy = xy(edges(:, 2), 2) - xy(edges(:, 1), 2);
%     angles = atan2(dy, dx);    
%     angles = mod(angles, pi);  % Ensure angles are positive
%     angles = rad2deg(angles);
%     edgeAngles(idx:idx+2) = angles';

    idx = idx + 3;

end
edgeLengths(idx:end) = [];  % remove excess zeros
medianLength = mean(edgeLengths);  % median of all edge lengths
minLength = medianLength * edgeThresh(1);  % minimum valid edge length
maxLength = medianLength * edgeThresh(2);  % maximum valid edge length

outsideLength = zeros(size(DT,1)*3, 1);
idx = 1;
i_phi = 1;
for i = 1:size(DT,1)
    triangle = DT(i,:);  % current triangle is 3 vertices
    edges = nchoosek(triangle,2);  % all 3x2 vertex combinations
    edgeLength = sqrt(sum((xy(edges(:,1),:) - xy(edges(:,2),:)).^2, 2));  % all three edge lengths
    
    % If one edge length is outside limits, remember bad triangle
    if any(edgeLength > maxLength | edgeLength < minLength)
        outsideLength(idx:idx+2) = triangle;
        idx = idx + 3;
    end

    % Calculate the angles of the triangle using atan2
    dx = xy(edges(:, 2), 1) - xy(edges(:, 1), 1);
    dy = xy(edges(:, 2), 2) - xy(edges(:, 1), 2);
    angles = atan2(dy, dx);    
    angles = mod(angles, pi);  % Ensure angles are positive
    angles = rad2deg(angles);

    % Append all neighbor distances to all vertices
    for j = 1:3
        for k = 1:2
            EL{edges(j,k)} = [EL{edges(j,k)} edgeLength(j)];
        end

        if edgeLength(j) <= maxLength && edgeLength(j) >= minLength
            edgeAngles(i_phi) = angles(j);
            i_phi = i_phi + 1;
        end
    end
end
edgeAngles(i_phi:end) = [];

% Remove bad triangles from Delaunay triangles
outsideLength = unique(outsideLength);
rowsToDelete = any(ismember(DT, outsideLength), 2);
DT(rowsToDelete, :) = [];

% Mean value of all neighbor distances for each point
edgeLengths = zeros(size(xy,1),1);
for i = 1:size(xy,1)
    edgeLengths(i) = mean(EL{i});
end

% Delete any remaining edge lengths outside of limits
edgeLengths = edgeLengths(edgeLengths <= maxLength);
edgeLengths = edgeLengths(edgeLengths >= minLength);