function [] = videoProcessingFun( filename,signname )

addpath(genpath('/eecf/cbcsl/data100/Qianli2/AASLIE2/AASLIE/FinalProgram_rearrange'));

% filename = '/eecf/cbcsl/data100/Qianli2/AASLIEforWeb/videoFolderAvi/15/15_M_S_05.avi';
% signname = 'H_S_3';

tempfilename = [filename(1:end-4),'.txt'];
resultfilename = strrep(tempfilename,'/eecf/cbcsl/data100/Qianli2/AASLIEforWeb/videoFolderAvi/',...
                                     '/eecf/cbcsl/data100/Qianli2/AASLIE2/AASLIE/FinalProgram_rearrange/resultFolder/');

[resultFolder,~,ext] = fileparts(resultfilename);
mkdir(resultFolder);
system(['chmod 777 ',resultFolder]);
fh = fopen(resultfilename, 'w');
system(['chmod 777 ',resultfilename]);

fprintf(fh, 'Uploading finished. Initializing processing algorithm....\n');
fprintf(fh, 'filename is: %s\n', filename);
fprintf(fh, 'signname is: %s\n', signname);


mainForTestingASample_fun_forweb ( filename, signname, fh );

fprintf(fh,'error occurs while processing video...');


fprintf(fh, 'finished');
fclose(fh);
copyfile(resultfilename,tempfilename);


end

