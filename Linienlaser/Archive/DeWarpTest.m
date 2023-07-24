function I = DeWarpTest(image)
% if image is stretched and shows ellipses instead of circles
% unstretch the image by finding the correct width

xMin = round(0.8 * size(image,2));  % minimum new realistic width
xMax = round(1.2 * size(image,2));  % maximum new realistic width


    function y = FindHough(x)
    % find hough circles and return the negative sum of circle metric
    % high metric means very orbiculate circles

        Ix = imresize(image, [size(image,1), x]);  % resize image width

        [~,~,metric] = imfindcircles(Ix, [6, 40]);  % find hough circles
        
        y = -sum(metric);  % sum of orbiculacity

    end

x = fminbnd(@(x) FindHough(x), xMin, xMax);  % find x of minimum

I = imresize(image, [size(image,1), x]);  % final resize

end