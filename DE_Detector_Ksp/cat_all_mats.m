%Code to combine the .mat files output from cat_click_times.m to get
%overall summary statistics and make plots of the detections from the
%entire deployment



inDir = 'C:\Users\Karlina.Merkens\Documents\KogiaSpp\DetectorCconcatOutput\Hawaii01';
GraphDir = 'C:\Users\Karlina.Merkens\Documents\KogiaSpp\DetectorCconcatOutput\Hawaii018\Final_histograms';

matList = dir(fullfile(inDir,'Haw*.mat')); % Add wildcard to match the files you want to process.

fs = 200000;

allclickDnum = [];
alldurClickcon = [];
allnDurcon = [];
allpeakFrcon = [];
allppSignalcon = [];
allspecClickTfcon = [];
allyFiltcon = [];
allmedianValues = [];
allmeanSpecClicks = [];
alliciEncs = [];


for i1 = 1:length(matList)
    load(fullfile(inDir,matList(i1).name), 'clickDnum','durClickcon',...
        'nDurcon', 'peakFrcon','ppSignalcon',...
        'specClickTfcon','yFiltcon','medianValues','meanSpecClicks','iciEncs')
    
    allclickDnum = [allclickDnum;clickDnum]; %save to one vector
    alldurClickcon = [alldurClickcon;durClickcon];
    allnDurcon = [allnDurcon; nDurcon];
    allpeakFrcon = [allpeakFrcon; peakFrcon];
    allppSignalcon = [allppSignalcon; ppSignalcon];
    allspecClickTfcon = [allspecClickTfcon; specClickTfcon];
    allyFiltcon = [allyFiltcon; yFiltcon];
    allmedianValues = [allmedianValues;medianValues];
    allmeanSpecClicks = [allmeanSpecClicks;meanSpecClicks];  
    alliciEncs = [alliciEncs;iciEncs];
     
end

numclicks = size(allclickDnum,1);
strnclicks = num2str(numclicks);
numenc = size(allmeanSpecClicks,1);
strnumenc = num2str(numenc);

filedate = datestr(now, 'yymmdd');

save([inDir,'_AllParamsConcat',filedate,'.mat'],...
'allclickDnum','alldurClickcon','allnDurcon','allpeakFrcon',...
'allppSignalcon','allspecClickTfcon','allyFiltcon','allmedianValues',...
'allmeanSpecClicks')

%Make plots and save them

%Click duration
meddurClick = prctile(alldurClickcon,50);
figure(1)
hist(alldurClickcon,50)
line([meddurClick meddurClick], [0 400],'Color','r','LineWidth',3);
text(0.5,0.9,['median = ',num2str(meddurClick),' \musec'],'Unit','normalized','Color','r')
ylim([0 400])
title(['Histgram of all click durations (\musec) (n = ',strnclicks,')']);
ylabel('Counts')
xlabel('Time (\musec)')
filename = fullfile(GraphDir,['Click_duration_',filedate]);
saveas(gca, filename, 'tif')
close(figure(1));

%nDur = Envelope duration
mednDur = prctile(allnDurcon,50);
figure(2)
hist(allnDurcon,25)
line([mednDur mednDur], [0 1050],'Color','r','LineWidth',3);
text(0.5,0.9,['median = ',num2str(mednDur),' \musec'],'Unit','normalized','Color','r')
ylim([0 1050])
title(['Histgram of all click envelope durations (us) (n = ',strnclicks,')']);
ylabel('Counts')
xlabel('Time (\musec)')
filename = fullfile(GraphDir,['Envelope_duration_',filedate]);
saveas(gca, filename, 'tif')
close(figure(2));


%PeakFrequency
medpeakFr = prctile(allpeakFrcon,50);
figure(3)
hist(allpeakFrcon,50)
line([medpeakFr medpeakFr], [0 600],'Color','r','LineWidth',3);
text(0.1,0.9,['median = ',num2str(medpeakFr),' kHz'],'Unit','normalized','Color','r')
ylim([0 600])
xlim([105 155])
title(['Histgram of all peak frequencies (kHz) (n = ',strnclicks,')']);
ylabel('Counts')
xlabel('Frequency (kHz)')
filename = fullfile(GraphDir,['Peak_Frequency_',filedate]);
saveas(gca, filename, 'tif')
close(figure(3));


%ppSignal
medppSig = prctile(allppSignalcon,50);
figure(4)
hist(allppSignalcon,50)
line([medppSig medppSig], [0 300],'Color','r','LineWidth',3);
text(0.5,0.9,['median = ',num2str(medppSig),' dB'],'Unit','normalized','Color','r')
ylim([0 300])
xlim([105 155])
title(['Histgram of all peak-peak amplitudes (n = ',strnclicks,')']);
ylabel('Counts')
xlabel('p-p amplitude (dB)')
filename = fullfile(GraphDir,['P-P_Amplitude_',filedate]);
saveas(gca, filename, 'tif')
close(figure(4));


%ici per encounter
mediciEncs = prctile(alliciEncs,50);
numicis = size(alliciEncs,1);
strnicis = num2str(numicis);
figure(5)
hist(alliciEncs,50)
line([mediciEncs mediciEncs], [0 375],'Color','r','LineWidth',3);
text(0.5,0.9,['median = ',num2str(mediciEncs),' msec'],'Unit','normalized','Color','r')
ylim([0 375])
% xlim([0 0.5])
title(['Histgram of all inter-click-intervals (n = ',strnicis,')']);
ylabel('Counts')
xlabel('Time (msec)')
filename = fullfile(GraphDir,['ICI_',filedate]);
saveas(gca, filename, 'tif')
close(figure(5));


%Next -plot the median values and mean spectra per encounter, perhaps on a multi plot? 
numMeds = size(allmedianValues,1);
strnMeds = num2str(numMeds);
titlecell = {'Peak Frequency', 'Inter-click-interval','Click Duration',...
    'Peak-to-peak amplitude';'(kHz)','(ms)','(\musec)', '(dB)';...
    'Frequency', 'Time','Time','Amplitude'};
figure(6)
for p = 1:4
    subplot(2,2,p)
    hist(allmedianValues(:,p),50);
    meanMed = nanmean(allmedianValues(:,p));
    text(0.1,0.9,['mean = ',num2str(meanMed),' ',titlecell{2,p}],'Unit','normalized','Color','r')
    title(titlecell{1,p});
    xlabel([titlecell{3,p},' ',titlecell{2,p}])
    ylabel('Counts')
end
text(-1,2.6,['Histgrams of median parameters per Encounter (n = ',strnMeds,')'],'Unit','normalized')
filename = fullfile(GraphDir,['MediansPerEncounter',filedate]);
saveas(gca, filename, 'tif')
close(figure(6));


%Then plot the mean spectra - could overlay with different colors
numSpecs = size(allmeanSpecClicks,1);
strnSpecs = num2str(numSpecs);
%Make frequency axis
numFreqBins = (size(allmeanSpecClicks,2))-1;
steps = (fs/2)/(numFreqBins-1);
freqs = (0:steps:(fs/2))/1000;
figure(7)
for p = 1:numSpecs
    plot(freqs,allmeanSpecClicks(p,2:end), 'Color',rand(1,3));
    hold on
end
title(['Mean Spectrum of Each Encounter (n = ',strnumenc,')']);
xlabel('Frequency (kHz)')
ylabel('Amplitude (dB)')
filename = fullfile(GraphDir,['MeanSpecPerEncounter',filedate]);
saveas(gca, filename, 'tif')
close(figure(7));
    
    
%make a time series!
figure(8)
hist(allclickDnum(:,1),77) %77 days between start and end of effort, to get clicks per day.
% ylim([0 375])
% xlim([0 0.5])
%Add grey boxes for no refording effort. Lines at july 27 and october 11 
dategapblocksX = [735781 735781 735807 735807 735885 735885 735903 735903];%values for bottoms and tops of squares to add [b,t,t,b]
dategapblocksY = [0 900 900 0 0 900 900 0];
hold on
grey = [0.8,0.8,0.8];
fill(dategapblocksX,dategapblocksY, grey);
current_day = datenum('Jul 15 2014'); %the date the plot starts
[Y, M, D, H, MN, S] = datevec(current_day);
current_day = addtodate(current_day, -D + 1,'day');
last_day = datenum('Oct 31 2014');
xlim([current_day last_day]);
xtick = [current_day];
xstep_length = 1; %one tick per month
xstep_unit = 'month';
while (last_day > current_day)
    xtick = [xtick addtodate(current_day, xstep_length, xstep_unit)];
    current_day = addtodate(current_day, xstep_length, xstep_unit);
end
ts = gca;
set(ts,'XTick', xtick,'XTickLabel', datestr(xtick,'mmm yy')); 
%,'FontSize',14
set(gca, 'Ticklength', [0 0])
set(gcf, 'renderer', 'zbuffer'); %removes the exponent from the date  
title(['Time Series of All Encounters (n = ',strnumenc,')']);
ylabel('Counts of Clicks per Day')
xlabel('Date') %Need something here to make this axis pretty with months/dates
filename = fullfile(GraphDir,['TS_',filedate]);
saveas(gca, filename, 'tif')
close(figure(8));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate some summary stats for each parameter

%Averages 
meandurClick = mean(alldurClickcon);
meannDur = mean(allnDurcon);
meanpeakFr = mean(allpeakFrcon);
meanppSignal = mean(allppSignalcon);
%meanspecClickTf = mean(allspecClickTfcon);
meaniciEncs = mean(alliciEncs);

%Standard Deviation
stddurClick = std(alldurClickcon);
stdnDur = std(allnDurcon);
stdpeakFr = std(allpeakFrcon);
stdppSignal = std(allppSignalcon);
%stdspecClickTf = std(allspecClickTfcon);
stdiciEncs = std(alliciEncs);

%medians (previously calculated)
meddurClick;
mednDur;
medpeakFr;
medppSig;
mediciEncs;

%kurtosis

%Skewness
skedurClick = skewness(alldurClickcon);
skenDur = skewness(allnDurcon);
skepeakFr = skewness(allpeakFrcon);
skeppSignal = skewness(allppSignalcon);
%skespecClickTf = skewness(allspecClickTfcon);
skeiciEncs = skewness(alliciEncs);

%Make one table, save it as .mat and .xls 
SummaryStats = [meandurClick meannDur meanpeakFr meanppSignal meaniciEncs;...
    meddurClick mednDur medpeakFr medppSig mediciEncs;...
    stddurClick stdnDur stdpeakFr stdppSignal stdiciEncs;...
    skedurClick skenDur skepeakFr skeppSignal skeiciEncs];


filename = fullfile(inDir,['SummaryStats_',filedate]);
save(filename, 'SummaryStats')
