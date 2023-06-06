% Synthetic XY graph
function ExportFiles(xy, hist_true, hist_synth, par)

if par.exportXY
    outFile = "Synth_" + par.inFileTrue;
    writematrix(xy, fullfile('UserData', outFile))
end

% True and synth histogram data
if par.exportHist
    hist_matrix = [hist_true.centers / par.df; hist_true.counts; ...
        hist_synth.counts; hist_true.accum; hist_synth.accum];
    
    outFile = strrep(par.inFileTrue, 'XY_', 'Hist_');
    writematrix(hist_matrix', fullfile('UserData', outFile), 'Delimiter', '\t')
end