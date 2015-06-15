% cat_click_times.m Code to take all the .mat output files from the
% detector and produce one .mat with all of the parameters concatenated for
% that directory, and to calculate the actual times of the clicks (relative
% to the baby jesus).  Also can call the plotting code to generate one set
% of plots for each encounter (not separated by .xwav file), unless the
% bottom section is commented out.
% Saves one summary .mat and one long list of start/end times as .xls (and
% plots, if requested)


%Set sampling frequency, in Hz
fs = 200000;

%inDir = 'E:\metadata\bigDL'; % the path to your directory of detector outputs goes here
inDir = 'E:\metadata\HAWAII01_disk09';
%inDir = 'C:\Users\Karlina.Merkens\Documents\Kogia\320_detectctor_dir\metadata\320_Detector_Test';
matList = dir(fullfile(inDir,'HAW*.mat')); % Add wildcard to match the files you want to process.
clickDnum = [];
durClickcon = [];
nDurcon = [];
peakFrcon = [];
ppSignalcon = [];
specClickTfcon = [];
specNoiseTfcon = [];
yFiltcon = [];

sec2dnum = 60*60*24; % conversion factor to get from seconds to matlab datenum
% iterate over detector-derived mat files in directory
for i1 = 1:length(matList)
    clickTimes = [];
    clickDnumTemp = [];
    % only need to load hdr and click times
    load(fullfile(inDir,matList(i1).name),'hdr','clickTimes', 'durClick', ...
        'nDur', 'peakFr','ppSignal','specClickTf','specNoiseTf','yFilt','f')
    if ~isempty(clickTimes)
    % determine true click times
        clickDnumTemp = (clickTimes./sec2dnum) + hdr.start.dnum + datenum([2000,0,0]);
        clickDnum = [clickDnum;clickDnumTemp]; %save to one vector
        durClickcon = [durClickcon;durClick];
        nDurcon = [nDurcon; nDur];
        peakFrcon = [peakFrcon; peakFr];
        ppSignalcon = [ppSignalcon; ppSignal];
        specClickTfcon = [specClickTfcon; specClickTf];
        specNoiseTfcon = [specNoiseTfcon; specNoiseTf];
        yFiltcon = [yFiltcon; yFilt];
        % write label file:
        clickTimeRel = zeros(size(clickDnumTemp));
        rawStarts = hdr.raw.dnumStart + datenum([2000,0,0]);
        rawDurs = (hdr.raw.dnumEnd-hdr.raw.dnumStart)*sec2dnum;
        % generate label file by replacing .mat extension with .lab for
        % wavesurfer:
        outFileName = strrep(matList(i1).name,'.mat','.lab');
        % open file for writing
        fidOut = fopen(fullfile(inDir,outFileName),'w+');
        for i2 = 1:size(clickTimes,1)
            % figure out the closest raw start less than the click start,
            % and subtract that time out of the click time, so it's not
            % relative
            thisRaw = find(rawStarts<=clickDnumTemp(i2,1),1,'last');
            clickTimeRel = (clickDnumTemp(i2,:) - rawStarts(thisRaw))*sec2dnum;
            % add back in the duration of recordings in seconds preceeding
            % this raw file
            if thisRaw>1
                clickTimeRel = clickTimeRel + sum(rawDurs(1:thisRaw-1));
            end
            % writes click number as third item in row, because some label
            % is needed:
            fprintf(fidOut, '%f %f %d\n', clickTimeRel(1,1),clickTimeRel(1,2),i2);
        end
        fclose(fidOut);
    end
end
choppedDir = strsplit(inDir,'\'); %cut up the file path to get the disk name
%so that you can save the files with identification. 
filedate = datestr(now, 'yymmdd');


%Added to save start/end times as character arrays
clickDnumChar1 = char(datestr(clickDnum(:,1)));
clickDnumChar2 = char(datestr(clickDnum(:,2)));
numclicks = size(clickDnum,1);
clickDnumChar = {};
for nc = 1:numclicks
    clickDnumChar{nc,1} = clickDnumChar1(nc,:);
    clickDnumChar{nc,2} = clickDnumChar2(nc,:);
end
xlswrite([inDir,'\',choppedDir{3},'_ClicksOnlyConcatCHAR',filedate,'.xls'],clickDnumChar)


%%%Section added to do post-processing where all the clicks are together,
%%%not speparted by xwav. 

%Get detectionTimes
%get excel file to read
[infile,inpath]=uigetfile('*.xls','Select .xls file to guide encounters');
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

%Use other code to do the plotting and get the medians.
%rename things
encounterTimes = matlabDates;
clickTimes = clickDnum;
guideDetector = 1;
ppSignal = ppSignalcon;
durClick = durClickcon;
specClickTf = specClickTfcon;
specNoiseTf = specNoiseTfcon;
peakFr = peakFrcon;
nDur = nDurcon;
yFilt = yFiltcon;
GraphDir = 'E:\metadata\matlab_graphs';


[medianValues,meanSpecClicks,iciEncs] = plotClickEncounters_posthoc_150310(encounterTimes,clickTimes,ppSignal,durClick,...
    specClickTf,specNoiseTf,peakFr,nDur,yFilt,hdr,GraphDir,fs);


%Then save everything
save([inDir,'\',choppedDir{3},'_ClicksOnlyConcat',filedate,'.mat'],...
    'clickDnum','durClickcon','nDurcon', 'peakFrcon','ppSignalcon',...
    'specClickTfcon','yFiltcon','medianValues','meanSpecClicks','iciEncs','f')




