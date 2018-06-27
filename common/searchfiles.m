function fnames = searchfiles(mfolder, ftype, startFolder, endFolder)

if (nargin < 3)
    startFolder = 0;
end;

subfolder = dir(mfolder);

if (nargin < 4)
    endFolder = length(subfolder)-3;
end;

fnames = {};
for i = 3+startFolder : 3+endFolder
    if(subfolder(i).isdir)
        dirFolder = dir([mfolder, subfolder(i).name, '\*', ftype]);
        for j = 1 : length(dirFolder)
            [pathstr, name, ext, versn] = fileparts(dirFolder(j).name);
            fnames = [fnames; subfolder(i).name,filesep,name];
        end;

        %%Check if the aim subfolder exist
        if(~exist([mfolder, subfolder(i).name], 'dir'))
            mkdir([mfolder, subfolder(i).name]);
        end;
    else
        [pathstr, name, ext, versn] = fileparts(subfolder(i).name);
        if(strcmpi(ext, ftype))
            fnames = [fnames; name];
        end;
    end;
end;

return;
