function [xwavNames,matlabDates,GraphDir] = guidedDetection(baseDir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in .xls file produced by logger
%%%%%%%%%%%  IMPORTANT STEP  %%%%%%%%%%%%%%%%%%
%   you must format your Excel dates/times as
%   NUMBERS.  to do this, highlight the start
%   and end date columns, right-click, select
%   'format cells', then choose 'Number', hit
%   OK, then save the spreadsheet.  You can
%   change them back to datestrings after you 
%   run this code.

%get excel file to read
[infile,inpath]=uigetfile('*.xls','Select .xls file to guide detector');
if isequal(infile,0)
    disp('Cancel button pushed');
    return
end

% inpath = 'C:\Users\Karlina.Merkens\Documents\Kogia\AnalysisLogs\HAWAII18K';
% infile = 'HAWAII18K_Ksp_Combo_ForDetector_150310.xls';

%read the file into 3 matrices-- numeric, text, and raw cell array
[num, txt, raw] = xlsread([inpath '\' infile]);

%error check
[~,y]=size(num);
if y < 2;          %start and end dates not formatted as numbers
    h=errordlg('Please save dates in number format and click ok');
    uiwait(h)
    [num, txt, raw] = xlsread([inpath '\' infile]); %reread file
end  

excelDates = num(:,1:2);                %numeric array contains datenums

%convert excel datenums to matlab datenums (different pivot year)
matlabDates = ones(size(excelDates)).*datenum('30-Dec-1899') ...
    + excelDates;

BaseDir = baseDir;
inDisk = fileparts(BaseDir(1:3));
MetaDir = ([BaseDir,'metadata']);
OutDir = ([MetaDir,'\click_params']);
GraphDir = ([MetaDir,'\matlab_graphs']);
mkdir(OutDir)
mkdir(GraphDir)

input_file = txt{2,1};
under = strfind(input_file, '_');
slash = strfind(input_file,'\');
depl = input_file(slash(1)+1:under(1)-1);
%depl = 'Hawaii18K';

%find folders on disk and remove those that don't belong to data
folders = dir(BaseDir);
foldersDepl = folders;
for fidx = 1:length(folders)
    true = strfind(folders(fidx).name, depl);
    other = strfind(folders(fidx).name, 'other');
    decim = strfind(folders(fidx).name, 'deci');
    if isempty(true) || ~isempty(decim) ||~isempty(other)
        trueIdx(fidx) = 0;
    else
        trueIdx(fidx) = 1;
    end
end
keep = find(trueIdx==1);
% OutDir = [];
foldernames = [];
for fidx = 1:length(keep)
    if isdir(fullfile(BaseDir,folders(keep(fidx)).name)) == 1
        foldernames = [foldernames; char(folders(keep(fidx)).name)];
    end
end
%pull out all x.wav files of all folders and combine in one long list
%together with directory information
allxwavNames = [];
for fidx = 1:size(foldernames,1)
    xwavDir = [BaseDir,foldernames(fidx,:)];
    xwavs = get_xwavNames(xwavDir);
    xwavList = [];
    for s = 1:size(xwavs,1)
        xwavList(s,:) = fullfile(foldernames(fidx,:),xwavs(s,:));
    end
    allxwavNames = [allxwavNames;char(xwavList)];
end

%parse out all dates and times for the start of each xwav file
ds = size(allxwavNames,2);
startFile = [];
for m = 1:size(allxwavNames,1)
    file = allxwavNames(m,:);
    dateFile = [str2num(['20',file(ds-18:ds-17)]),str2num(file(ds-16:ds-15)),...
        str2num(file(ds-14:ds-13)),str2num(file(ds-11:ds-10)),...
        str2num(file(ds-9:ds-8)),str2num(file(ds-7:ds-6))];
    startFile = [startFile; datenum(dateFile)];
end

%take each detection, check which xwav files are associated with the detection
xwavNames = [];
for i = 1:size(matlabDates,1)   
    %find which xwav file(s) correspond(s) with manual detection start 
    start = matlabDates(i,1);
    fileIdx = find(startFile<start);
    startIdx = find(startFile == startFile(fileIdx(end))); %check for multiple matlab files per x.wav
    
    fend = matlabDates(i,2);
    fileIdx = find(startFile>fend);
    if isempty(fileIdx)
        filetext = fullfile(BaseDir,'click_params', (sprintf('%s_%s', depl,datestr(matlabDates(i,1),30),'.txt')));
        fid = fopen(filetext,'w+');
        disp('End time possibly on next disk');
        fprintf(fid,'%s','End time possibly on next disk');
        fclose(fid);
        
        if startIdx(end)<length(startFile)
            fileIdx = length(startFile)+1;
        end
    end
    
    if ~isempty(fileIdx)
        endIdx = find(startFile == startFile(fileIdx(1)-1));%check for multiple matlab files per x.wav
    
        fIdx = [startIdx:endIdx]; %combine all indices of files associate with this detection
        fIdx = unique(fIdx);        
        detxwavNames = allxwavNames(fIdx,:);
        xwavNames = [xwavNames; detxwavNames];       
    end
end

xwavNames = unique(xwavNames,'rows');
