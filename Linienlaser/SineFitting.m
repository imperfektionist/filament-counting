% Clear any existing variables and close all figures
% clear all;
% close all;

% Read the data from the "eccentricity.txt" file
file_name = 'eccentricity.txt';
data = load(file_name);

% Assuming the data in the file is a vector, we can extract the x and y values.
% If the data is in two columns, you can use:
% x = data(:, 1);
% y = data(:, 2);

n = round(length(data));
y = data(1:100:n);

x = 1:length(y);  % Assume x values are just indices of data points

% Perform sinusoidal fitting using the provided approach
yu = max(y);
yl = min(y);
yr = (yu - yl);                             % Range of ‘y’
yz = y - yu + (yr/2);

%%
zx = x(yz .* circshift(yz, [0 1]) <= 0);     % Find zero-crossings
% per = 2 * mean(diff(zx));                   % Estimate period
per = length(y);
ym = mean(y);                               % Estimate offset
fit = @(b, x) b(1) .* (sin(2 * pi * x ./ b(2) + 2 * pi / b(3))) + b(4);    % Function to fit
fcn = @(b) sum((fit(b, x) - y).^2);         % Least-Squares cost function
s = fminsearch(fcn, [yr/2; per; -1; ym]);     % Minimize Least-Squares

% Generate values from the fitted model to plot the sine curve
xp = linspace(min(x), max(x), length(y));

% Plot the original data and the fitted sine curve
figure;
plot(x, y, 'k', 'LineWidth', 2); % Plot the data points
hold on;
yp = fit(s, xp);
plot(xp, yp, 'r', 'LineWidth', 2); % Plot the fitted sine curve

extrema = sprintf("Max: %.3f \nMin: %.3f \nDiff: %.3f",...
    max(yp),min(yp),max(yp)-min(yp));
text(10,max(yp),extrema)
text(10,min(yp),extrema)
xlabel('Data Index');
ylabel('Eccentricity');
title('Sinusoidal Fitting of Eccentricity Data');
legend('Data', 'Fitted Sine Curve');
grid on;
hold off;

writematrix(horzcat(x',y'), "eccentricity_fitted.txt", 'Delimiter','\t')
% writematrix(horzcat(y',yp'), "eccentricity_fitted.txt", 'Delimiter','\t')
