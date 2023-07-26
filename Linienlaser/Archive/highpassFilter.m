function filteredImage = highpassFilter(grayImage)

% Create a high-pass filter kernel (Laplacian kernel)
laplacianKernel = [0 -1 0; -1 4 -1; 0 -1 0];

% Apply the high-pass filter using imfilter
filteredImage = imfilter(double(grayImage), laplacianKernel);

% Adjust scaling and add the filtered result back to the original image to create a sharpened image
sharpened = filteredImage; %+ double(grayImage);

% Ensure the pixel values are within the valid range (0-255 for uint8 images)
filteredImage = uint8(sharpened);
