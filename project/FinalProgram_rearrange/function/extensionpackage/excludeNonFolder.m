function [ FolderDir ] = excludeNonFolder( FolderDir )
% Exclude the non-folder elements in the directory structure
%   The Folder Directory may contain the non folder element

for folderIdx = length(FolderDir):-1:1 % the reason of decreasing index is to avoid 
    if strcmp(FolderDir(folderIdx).name,'.') | ...
              strcmp(FolderDir(folderIdx).name,'..') | ...
              strcmp(FolderDir(folderIdx).name,'.DS_Store')
        FolderDir(folderIdx) = [];
    end
end    

end

