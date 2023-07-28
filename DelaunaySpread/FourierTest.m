% Test another approach for filament distribution modeling
xy = readmatrix("UserData/BU2281_LR_COLL.txt");

doMagnitude = 0;
magnitude_noise = 0.0;
phase_noise = 0.01;

% Step 1: Compute the Discrete Fourier Transform (DFT)
dft_xy = fft2(xy);

% Step 2: Calculate the magnitudes and phases of the Fourier coefficients
magnitudes = abs(dft_xy);
phases = angle(dft_xy);

% Assuming you have computed the magnitude spectrum as 'magnitudes' (from previous code)
% Define a scaling factor for the perturbation (adjust the value as needed)

if doMagnitude
    % Generate random perturbations for the magnitudes
    perturbations = 1 + magnitude_noise * rand(size(magnitudes));
    % Apply the perturbations to the magnitude spectrum
    magnitudes = magnitudes .* perturbations;
    % Reconstruct the complex Fourier coefficients with the modified magnitude spectrum
    dft_xy = magnitudes .* exp(1i * phases);
    % Reconstruct the modified point set using inverse DFT (optional)
    reconstructed_xy = ifft2(dft_xy);
else
    % Generate random perturbations for the phases
    perturbations = phase_noise * (2 * rand(size(phases)) - 1);
    % Apply the perturbations to the phase spectrum
    phases = phases + perturbations;
    % Reconstruct the complex Fourier coefficients with the modified phase spectrum
    dft_xy = magnitudes .* exp(1i * phases);
    % Reconstruct the modified point set using inverse DFT (optional)
    reconstructed_xy = ifft2(dft_xy);
end


% Step 3: Visualize the results

% Original 2D point set
figure;
% subplot(2, 2, 1);
scatter(xy(:, 1), xy(:, 2));
title('Original Point Set');
xlabel('X-axis');
ylabel('Y-axis');
axis([0 20 -10 10]);
axis equal

% % Magnitude spectrum
% figure;
% % subplot(2, 2, 2);
% imagesc(log(1 + fftshift(magnitudes)));
% colorbar;
% title('Magnitude Spectrum');
% xlabel('Frequency (k_x)');
% ylabel('Frequency (k_y)');

% % Phase spectrum
% figure;
% % subplot(2, 2, 3);
% imagesc(fftshift(phases));
% colorbar;
% title('Phase Spectrum');
% xlabel('Frequency (k_x)');
% ylabel('Frequency (k_y)');

% Reconstructed point set using inverse DFT (optional)
% reconstructed_xy = ifft2(dft_xy);

figure;
% subplot(2, 2, 4);
scatter(real(reconstructed_xy(:, 1)), real(reconstructed_xy(:, 2)), 'r');
title('Reconstructed Point Set');
xlabel('X-axis');
ylabel('Y-axis');
axis([0 20 -10 10]);
axis equal

% Adjust subplot layout for better visualization
% sgtitle('Fourier Analysis of 2D Point Set');

% Note: The 'real' function is used in the reconstruction plot to remove any small
% imaginary components that may arise due to numerical errors in the computations.
