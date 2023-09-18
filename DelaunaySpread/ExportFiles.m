% Synthetic XY graph
function ExportFiles(xy_synth, hist_true, hist_synth, angles_true, angles_synth, par)

outFile = "Synth_" + par.inFileTrue;
if par.exportXY    
    xy = RemovePadding(xy_synth, par);
    writematrix(xy, fullfile('UserData', outFile))
end

% True and synth histogram data
if par.exportHist
% %     hist_matrix = [hist_true.centers / par.df; hist_true.counts; ...
% %         hist_synth.counts; hist_true.accum; hist_synth.accum];
%     hist_matrix = [hist_true.centers; hist_true.counts; 
%         hist_synth.centers; hist_synth.counts];
    hist_matrix = [hist_synth.centers'; hist_synth.counts'];
    
    outFile = strrep(outFile, 'Synth_', 'Hist_');
    writematrix(hist_matrix', fullfile('UserData', outFile), 'Delimiter', '\t')

%     %header = {'CentersTrue' 'CountsTrue' 'CountsSynth' 'AccumTrue' 'AccumSynth'};
%     header = {'CentersTrue' 'CountsTrue' 'CountsSynth'};
%     T = array2table(hist_matrix', 'VariableNames', header);
%     writetable(T, fullfile('UserData', outFile), 'Delimiter', '\t');

%     hist_matrix = [angles_true.centers; angles_true.counts'; angles_synth.counts'];
    hist_matrix = [angles_synth.counts'];
    
    outFile = strrep(outFile, 'Hist_', 'Angles_');
    writematrix(hist_matrix', fullfile('UserData', outFile), 'Delimiter', '\t')

end