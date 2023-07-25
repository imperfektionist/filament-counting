function data = detrend2(data)

cutoff = -5;

data(data < cutoff) = NaN;

maxVal = max(data(:));
minVal = min(data(:));

data = (data - minVal) / (maxVal - minVal);

data(data <= 0.001) = NaN;