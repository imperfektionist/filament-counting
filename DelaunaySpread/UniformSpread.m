function [xy_synth, par] = UniformSpread(xy_true, par)

% Border points are missing
lim_true = par.lim_true;

% Synthetic brush dimensions
lim_synth.xmin = 0;
lim_synth.xmax = par.brushDiameter * pi;
lim_synth.ymin = -par.brushWidth / 2;
lim_synth.ymax = par.brushWidth / 2;

par.lim_synth = lim_synth;  % save before padding

% Add padding margin around synthetic distribution
lim_synth.xmin = lim_synth.xmin - par.padWidth;
lim_synth.xmax = lim_synth.xmax + par.padWidth;
lim_synth.ymin = lim_synth.ymin - par.padWidth;
lim_synth.ymax = lim_synth.ymax + par.padWidth;

N_true = size(xy_true, 1);  % true filament number

area_true = (lim_true.xmax - lim_true.xmin) * (lim_true.ymax - lim_true.ymin);
area_synth = (lim_synth.xmax - lim_synth.xmin) * (lim_synth.ymax - lim_synth.ymin);

rho = N_true / area_true;  % filament density

N_synth = round(rho * area_synth);  % synthetic number of filaments

% Generate random X and Y values
% xy_synth = zeros(N_synth, 2);  % init
% xy_synth(:,1) = rand(N_synth,1) * (lim_synth.xmax - lim_synth.xmin) + lim_synth.xmin;
% xy_synth(:,2) = rand(N_synth,1) * (lim_synth.ymax - lim_synth.ymin) + lim_synth.ymin;

% Start with square distribution
b = lim_synth.xmax - lim_synth.xmin;  % width of area
h = lim_synth.ymax - lim_synth.ymin;
Nb = round(sqrt(b / h * N_synth));  % horizontal number of filaments
Nh = round(sqrt(h / b * N_synth));  % vertical number of filaments
db = b / (Nb - 1);  % horizontal distance between filaments
dh = h / (Nh - 1);  % vertical distance between filaments

Nf = Nb * Nh;  % recalculate total number

xy_synth = zeros(Nf, 2);  % init
xy_rand_phi = rand(Nf,1) * 2 * pi;  % noise angle
xy_rand_rad = rand(Nf,1) * par.df;  % noise radius

i = 1;
for y = 1:Nh  % cycle through grid rows
    for x = 1:Nb  % cycle through grid columns
        noise = xy_rand_rad(i) * [cos(xy_rand_phi(i)) sin(xy_rand_phi(i))];
        xy_synth(i,1) = lim_synth.xmin + x * db + noise(1);
        xy_synth(i,2) = lim_synth.ymin + y * dh + noise(2);
        i = i + 1;
    end
end

if Nf > N_synth  % placed to many filaments
    xy_synth = xy_synth(1:i-1,:);  % remove
    
elseif Nf < N_synth  % placed not enough filaments
    for i = i:N_synth  % add random
        xy_synth(i,1) = rand * (lim_synth.xmax - lim_synth.xmin) + lim_synth.xmin;
        xy_synth(i,2) = rand * (lim_synth.ymax - lim_synth.ymin) + lim_synth.ymin;
    end
end