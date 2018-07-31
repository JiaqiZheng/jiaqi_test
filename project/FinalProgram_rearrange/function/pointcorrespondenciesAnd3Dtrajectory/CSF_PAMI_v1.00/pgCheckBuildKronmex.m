
function [] = pgCheckBuildKronmex()

try 
    kronmex( eye(2), eye(3) );       % simply attempt to run mex-file
    
catch Exception
    
    disp('ERROR running "kronmex" mex-file. Will now compile source code:')
    mex kronmex.c
end