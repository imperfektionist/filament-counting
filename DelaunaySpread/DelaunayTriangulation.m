function [DT, edgeLengths] = DelaunayTriangulation(xy, edgeThresh)

% Compute Delaunay triangulation
DT = delaunay(xy(:,1), xy(:,2));

% Pre-initialize edge lengths matrix
edgeLengths = zeros(size(DT,1)*3, 1);

% Compute edge lengths
idx = 1;
for i = 1:size(DT,1)
    triangle = DT(i,:);
    edges = nchoosek(triangle,2);
    edgeLengths(idx:idx+2) = sqrt(sum((xy(edges(:,1),:) - xy(edges(:,2),:)).^2, 2));
    idx = idx + 3;
end
edgeLengths(idx:end) = []; % Remove excess zeros
medianLength = median(edgeLengths);
minLength = medianLength * edgeThresh(1);
maxLength = medianLength * edgeThresh(2);

outsideLength = zeros(size(DT,1)*3, 1);
idx = 1;
for i = 1:size(DT,1)
    triangle = DT(i,:);
    edges = nchoosek(triangle,2);
    edgeLength = sqrt(sum((xy(edges(:,1),:) - xy(edges(:,2),:)).^2, 2));
    
    if any(edgeLength > maxLength | edgeLength < minLength)
        outsideLength(idx:idx+2) = triangle;
        idx = idx + 3;
    end
end
outsideLength = unique(outsideLength);
rowsToDelete = any(ismember(DT, outsideLength), 2);
DT(rowsToDelete, :) = [];

edgeLengths = edgeLengths(edgeLengths < 2);