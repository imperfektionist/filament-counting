function image = CropToROI(Irgb)
% Crop image I by removing the black parts

c = 10;

image = im2gray(Irgb);

% Initial crop against black margins
image = image(c:size(image,1)-c, c:size(image,2)-c);

% Find the indices of the first non-black pixel from the top and bottom
topRow = find(any(image, 2), 1, 'first');
bottomRow = find(any(image, 2), 1, 'last');

vertSum = sum(image,1);
leftCol = find(vertSum == 0, 1, 'first');
rightCol = find(vertSum == 0, 1, 'last');

image = image(topRow:bottomRow, leftCol:rightCol);

% Find the indices of the first non-black pixel from the left and right
leftCol = find(any(image, 1), 1, 'first');
rightCol = find(any(image, 1), 1, 'last');

% Crop the image using the identified indices
image = image(1:size(image,1), leftCol:rightCol);

