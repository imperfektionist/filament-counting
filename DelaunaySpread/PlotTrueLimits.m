% Rectangular outline to mark true spacial limits
function PlotTrueLimits(fig, lim, col)

set(0, 'CurrentFigure', fig)

x = lim.xmin;
y = lim.ymin;
w = lim.xmax - x;
h = lim.ymax - y;

rectangle('Position', [x y w h], 'EdgeColor', col);