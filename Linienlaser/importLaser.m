function dataArray = importLaser(par)

fullPathDP = fullfile(par.userPath, join(['DP_' par.csvFileName],''));

if ~exist(fullPathDP, "file")  % decimal point file does not exist yet
    fprintf("Importing %s\n", par.csvFileName)
    
    fullFilePath = fullfile(par.dataPath, par.csvFileName);  % full path
    fileContent = fileread(fullFilePath);  % import CSV file
    fileContent = strrep(fileContent, ',', '.');  % replace commas
    
    % Write the modified content to a new file (decimal point)
    newFileName = join(['UserData/DP_' par.csvFileName],'');
    newFile = fopen(newFileName, 'w');
    fprintf(newFile, '%s', fileContent);
    fclose(newFile);
    dataArray = readmatrix(newFileName);  % import as matrix
        
else  % decimal point file already exists
    fprintf("Importing %s\n", fullPathDP)
    dataArray = readmatrix(fullPathDP);  % import as matrix
end
