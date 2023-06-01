function CountNeighbors(xy, DT)


n = size(xy, 1);
countNeighbors = zeros(n,1);
for i = 1:n
    countNeighbors(i) = sum(DT(:) == i);
end
countNeighbors(countNeighbors == 0) = [];
histogram(countNeighbors)