rsq = readmatrix("UserData\Rsq_Map.txt")';

p = [3.6];
i = 0:40;

[maxVal, linInd] = max(rsq(:));  % find maximum Rsq
[pInd, iterInd] = ind2sub(size(rsq), linInd);  % get indices
tit = sprintf('R^2: %.1f, i: %d, p_ε: %.2f', ...
    maxVal*100, i(iterInd), p(pInd));

figure;
zmax = max(rsq,[],2);
% z = rsq(:,end);
plot(p, zmax, 'k', 'LineWidth', 2)
hold on
zmed = median(rsq,2);
plot(p, zmed, 'm', 'LineWidth', 2)
legend('max','median')
title(tit)
xlabel('Synth error exponent p_ε')
ylabel('R^2')
rsq_perr = horzcat(p', zmax);
writematrix(rsq_perr, 'UserData\Rsq_perr.txt', 'Delimiter', '\t')


figure;
zmax = max(rsq,[],1);
% z = rsq(37,:);
plot(i, zmax, 'k', 'LineWidth', 2)
hold on
zmed = median(rsq,1);
plot(i, zmed, 'm', 'LineWidth', 2)
legend('max','median')
title(tit)
xlabel('Number of iterations i')
ylabel('R^2')


rsq_iter = horzcat(i', zmax');
writematrix(rsq_iter, 'UserData\Rsq_iter.txt', 'Delimiter', '\t')

% figure;
% surf(p, i, rsq, 'EdgeColor', 'none');
% hold on
% plot3(p, maxInd, maxVals+1)
% colormap('bone')  % parula, turbo, bone, hot
% colorbar
% view(0, 90);
% xlim([0 10]);
% ylim([0 24]);
% zlim([0.3 1])
% title(tit)    
