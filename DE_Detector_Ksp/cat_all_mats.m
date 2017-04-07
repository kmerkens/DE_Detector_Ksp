%Code to combine the .mat files output from cat_click_times.m to get
%overall summary statistics and make plots of the detections from the
%entire deployment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Load data
inDir = 'C:\Users\Karlina.Merkens\Documents\Kogia\DetectorOutput\Hawaii18';
GraphDir = 'C:\Users\Karlina.Merkens\Documents\Kogia\DetectorOutput\Hawaii18\Final_histograms';

matList = dir(fullfile(inDir,'Haw*.mat')); % Add wildcard to match the files you want to process.

fs = 320000;

allclickDnum = [];
alldurClickcon = [];
allnDurcon = [];
allpeakFrcon = [];
allppSignalcon = [];
allspecClickTfcon = [];
allspecNoiseTfcon = [];
allyFiltcon = [];
allmedianValues = [];
allmeanSpecClicks = [];
allmeanSpecNoises = [];
alliciEncs = [];

%%Concatenate data from all .mat files
for i1 = 1:length(matList)
    load(fullfile(inDir,matList(i1).name), 'clickDnum','durClickcon',...
        'nDurcon', 'peakFrcon','ppSignalcon','specClickTfcon',...
        'specNoiseTfcon','yFiltcon','medianValues','meanSpecClicks','meanSpecNoises',...
        'iciEncs','f')
    
    allclickDnum = [allclickDnum;clickDnum]; %save to one vector
    alldurClickcon = [alldurClickcon;durClickcon];
    allnDurcon = [allnDurcon; nDurcon];
    allpeakFrcon = [allpeakFrcon; peakFrcon];
    allppSignalcon = [allppSignalcon; ppSignalcon];
    allspecClickTfcon = [allspecClickTfcon; specClickTfcon];
    allspecNoiseTfcon = [allspecNoiseTfcon; specNoiseTfcon];
    allyFiltcon = [allyFiltcon; yFiltcon];
    allmedianValues = [allmedianValues;medianValues];
    allmeanSpecClicks = [allmeanSpecClicks;meanSpecClicks];
    allmeanSpecNoises = [allmeanSpecNoises;meanSpecNoises];
    alliciEncs = [alliciEncs;iciEncs];
     
end

numclicks = size(allclickDnum,1);
strnclicks = num2str(numclicks);
numenc = size(allmeanSpecClicks,1);
strnumenc = num2str(numenc);

filedate = datestr(now, 'yymmdd');

save([inDir,'\AllParamsConcat',filedate,'.mat'],...
'allclickDnum','alldurClickcon','allnDurcon','allpeakFrcon',...
'allppSignalcon','allspecClickTfcon','allspecNoiseTfcon','allyFiltcon',...
'allmedianValues','allmeanSpecClicks','allmeanSpecNoises')
<<<<<<< HEAD


=======


>>>>>>> 18dfc1fa0cdc4fadefafaa1d6da05aff354aa79f
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate 25th, median and 75th percentiles for median values, to give some sense
%of width of the histogram spans. 
Q1peakFr = prctile(allpeakFrcon,25);
Q1iciEncs = prctile(alliciEncs,25);
Q1durClick = prctile(alldurClickcon,25);
Q1nDur = prctile(allnDurcon,25);
Q1ppSig = prctile(allppSignalcon,25);

medpeakFr = prctile(allpeakFrcon,50);
mediciEncs = prctile(alliciEncs,50);
meddurClick = prctile(alldurClickcon,50);
mednDur = prctile(allnDurcon,50);
medppSig = prctile(allppSignalcon,50);
<<<<<<< HEAD

Q3peakFr = prctile(allpeakFrcon,75);
Q3iciEncs = prctile(alliciEncs,75);
Q3durClick = prctile(alldurClickcon,75);
Q3nDur = prctile(allnDurcon,75);
Q3ppSig = prctile(allppSignalcon,75);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make plots and save them

=======

Q3peakFr = prctile(allpeakFrcon,75);
Q3iciEncs = prctile(alliciEncs,75);
Q3durClick = prctile(alldurClickcon,75);
Q3nDur = prctile(allnDurcon,75);
Q3ppSig = prctile(allppSignalcon,75);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make plots and save them

>>>>>>> 18dfc1fa0cdc4fadefafaa1d6da05aff354aa79f
% %Click duration
% figure(1)
% hist(alldurClickcon,50)
% line([meddurClick meddurClick], [0 800],'Color','r','LineWidth',3);
% line([Q1durClick Q1durClick], [0 800],'Color','r','LineWidth',2,'LineStyle',':');
% line([Q3durClick Q3durClick], [0 800],'Color','r','LineWidth',2,'LineStyle',':');
% text(0.5,0.9,['25th pctile = ',num2str(Q1durClick),' \musec'],'Unit','normalized','Color','r')
% text(0.5,0.85,['median = ',num2str(meddurClick),' \musec'],'Unit','normalized','Color','r')
% text(0.5,0.8,['75th pctile = ',num2str(Q3durClick),' \musec'],'Unit','normalized','Color','r')
% %ylim([0 400])
% title(['Histgram of all click durations (\musec) (n = ',strnclicks,')']);
% ylabel('Counts')
% xlabel('Time (\musec)')
% filename = fullfile(GraphDir,['Click_duration_',filedate]);
% saveas(gca, filename, 'tif')
% saveas(gca, filename, 'jpg')
% close(figure(1));
% 
% %nDur = Envelope duration
% figure(2)
% hist(allnDurcon,25)
% line([mednDur mednDur], [0 700],'Color','r','LineWidth',3);
% line([Q1nDur Q1nDur], [0 700],'Color','r','LineWidth',2,'LineStyle',':');
% line([Q3nDur Q3nDur], [0 700],'Color','r','LineWidth',2,'LineStyle',':');
% text(0.6,0.9,['25th pctile = ',num2str(Q1nDur),' \musec'],'Unit','normalized','Color','r')
% text(0.6,0.85,['median = ',num2str(mednDur),' \musec'],'Unit','normalized','Color','r')
% text(0.6,0.8,['75th pctile = ',num2str(Q3nDur),' \musec'],'Unit','normalized','Color','r')
% %ylim([0 1050])
% title(['Histgram of all click envelope durations (\musec) (n = ',strnclicks,')']);
% ylabel('Counts')
% xlabel('Time (\musec)')
% filename = fullfile(GraphDir,['Envelope_duration_',filedate]);
% saveas(gca, filename, 'tif')
% saveas(gca, filename, 'jpg')
% close(figure(2));
% 
% 
% %PeakFrequency
% figure(3)
% hist(allpeakFrcon,25)
% line([medpeakFr medpeakFr], [0 1600],'Color','r','LineWidth',3);
% line([Q1peakFr Q1peakFr], [0 1600],'Color','r','LineWidth',2,'LineStyle',':');
% line([Q3peakFr Q3peakFr], [0 1600],'Color','r','LineWidth',2,'LineStyle',':');
% text(0.1,0.9,['25th pctile = ',num2str(Q1peakFr,3),' kHz'],'Unit','normalized','Color','r')
% text(0.1,0.85,['median = ',num2str(medpeakFr,3),' kHz'],'Unit','normalized','Color','r')
% text(0.1,0.8,['75th pctile = ',num2str(Q3peakFr,3),' kHz'],'Unit','normalized','Color','r')
% %ylim([0 600])
% %xlim([105 155])
% title(['Histgram of all peak frequencies (kHz) (n = ',strnclicks,')']);
% ylabel('Counts')
% xlabel('Frequency (kHz)')
% filename = fullfile(GraphDir,['Peak_Frequency_',filedate]);
% saveas(gca, filename, 'tif')
% saveas(gca, filename, 'jpg')
% close(figure(3));
% 
% 
% %ppSignal
% figure(4)
% hist(allppSignalcon,50)
% line([medppSig medppSig], [0 500],'Color','r','LineWidth',3);
% line([Q1ppSig Q1ppSig], [0 500],'Color','r','LineWidth',2,'LineStyle',':');
% line([Q3ppSig Q3ppSig], [0 500],'Color','r','LineWidth',2,'LineStyle',':');
% text(0.6,0.9,['25th pctile = ',num2str(Q1ppSig,3),' dB'],'Unit','normalized','Color','r')
% text(0.6,0.85,['median = ',num2str(medppSig,3),' dB'],'Unit','normalized','Color','r')
% text(0.6,0.8,['75th pctile = ',num2str(Q3ppSig,3),' dB'],'Unit','normalized','Color','r')
% %ylim([0 300])
% %xlim([105 155])
% title(['Histgram of all peak-peak amplitudes (n = ',strnclicks,')']);
% ylabel('Counts')
% xlabel('p-p amplitude (dB)')
% filename = fullfile(GraphDir,['P-P_Amplitude_',filedate]);
% saveas(gca, filename, 'tif')
% saveas(gca, filename, 'jpg')
% close(figure(4));
% 
% 
% %ici per encounter
% numicis = size(alliciEncs,1);
% strnicis = num2str(numicis);
% figure(5)
% hist(alliciEncs,50)
% line([mediciEncs mediciEncs], [0 900],'Color','r','LineWidth',3);
% line([Q1iciEncs Q1iciEncs], [0 900],'Color','r','LineWidth',2,'LineStyle',':');
% line([Q3iciEncs Q3iciEncs], [0 900],'Color','r','LineWidth',2,'LineStyle',':');
% text(0.5,0.9,['25th pctile = ',num2str(Q1iciEncs,3),' msec'],'Unit','normalized','Color','r')
% text(0.5,0.85,['median = ',num2str(mediciEncs,3),' msec'],'Unit','normalized','Color','r')
% text(0.5,0.8,['75th pctile = ',num2str(Q3iciEncs,3),' msec'],'Unit','normalized','Color','r')
% %ylim([0 375])
% % xlim([0 0.5])
% title(['Histgram of all inter-click-intervals (n = ',strnicis,')']);
% ylabel('Counts')
% xlabel('Time (msec)')
% filename = fullfile(GraphDir,['ICI_',filedate]);
% saveas(gca, filename, 'tif')
% saveas(gca, filename, 'jpg')
% close(figure(5));
% 
% 
% %Next -plot the median values
% numMeds = size(allmedianValues,1);
% strnMeds = num2str(numMeds);
% titlecell = {'Peak Frequency', 'Inter-click-interval','Click Duration',...
%     'Peak-to-peak amplitude';'(kHz)','(ms)','(\musec)', '(dB)';...
%     'Frequency', 'Time','Time','Amplitude'};
% figure(6)
% for p = 1:4
%     subplot(2,2,p)
%     hist(allmedianValues(:,p),30);
%     meanMed = nanmean(allmedianValues(:,p));
%     text(0.1,0.9,['mean = ',num2str(meanMed,3),' ',titlecell{2,p}],'Unit','normalized','Color','r')
%     title(titlecell{1,p});
%     xlabel([titlecell{3,p},' ',titlecell{2,p}])
%     ylabel('Counts')
% end
% text(-1,2.55,['Histgrams of median parameters per Encounter (n = ',strnMeds,')'],'Unit','normalized')
% filename = fullfile(GraphDir,['MediansPerEncounter',filedate]);
% saveas(gca, filename, 'tif')
% saveas(gca, filename, 'jpg')
% close(figure(6));


%Then plot the mean spectra - could overlay with different colors
numSpecs = size(allmeanSpecClicks,1);
strnSpecs = num2str(numSpecs);
%Make frequency axis
numFreqBins = (size(allmeanSpecClicks,2))-1;
%steps = (fs/2)/(numFreqBins-1);
%freqs = (0:steps:(fs/2))/1000;
freqs = f;
figure(7)
for p = 1:numSpecs
    %plot(freqs,allmeanSpecClicks(p,2:end), 'Color',rand(1,3));
<<<<<<< HEAD
    plot(freqs,allmeanSpecClicks(p,2:end), 'Color','k','LineWidth',1);
    hold on
    plot(freqs,allmeanSpecNoises(p,2:end), 'Color',[0.7, 0.7, 0.7], 'LineWidth',1);
=======
    plot(freqs,allmeanSpecClicks(p,2:end), 'Color','k');
    hold on
    plot(freqs,allmeanSpecNoises(p,2:end), 'Color',[0.8, 0.8, 0.8], 'LineStyle',':');
>>>>>>> 18dfc1fa0cdc4fadefafaa1d6da05aff354aa79f
end
legend('mean click','mean noise','Location','southwest')
title(['Mean Spectrum of Each Encounter (n = ',strnumenc,')']);
xlabel('Frequency (kHz)')
ylabel('Amplitude (dB)')
filename = fullfile(GraphDir,['MeanSpecPerEncounter',filedate]);
saveas(gca, filename, 'tif')
saveas(gca, filename, 'jpg')
close(figure(7));
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Then combine all spectra and calculate one mean, plot with the mean noise
%from the first file.
%First, calculate the mean. start by looping through all the entries in the
%cell array and saving those to a non-cell matrix
numspecClick = size(allspecClickTfcon,1);
concatspecs = [];
for s = 1:numspecClick
        concatspecs = [concatspecs;allspecClickTfcon{s,1}'];
end
grandmeanSpec = mean(concatspecs);

%Make frequency axis
numFreqBins = (size(allmeanSpecClicks,2))-1;
freqs = f;

figure(8)
<<<<<<< HEAD
plot(freqs,grandmeanSpec(1,1:end), 'Color','k','LineWidth',1);
hold on
plot(freqs,allmeanSpecNoises(1,2:end), 'Color',[0.7, 0.7, 0.7], 'LineWidth',1);
xlim([0 200]);
legend('mean click','mean noise','Location','southwest')
title(['Mean Spectrum of all Clicks (n = ',num2str(numspecClick),')']);
xlabel('Frequency (kHz)')
ylabel('Amplitude (dB)')
filename = fullfile(GraphDir,['MeanSpecGrand',filedate]);
=======
hist(allclickDnum(:,1),77) %77 days between start and end of effort, to get clicks per day.
ylim([0 1300])
% xlim([0 0.5])
%Add grey boxes for no refording effort. Lines at july 27 and october 11 
dategapblocksX = [735781 735781 735807 735807 735885 735885 735903 735903];%values for bottoms and tops of squares to add [b,t,t,b]
dategapblocksY = [0 1300 1300 0 0 1300 1300 0];
hold on
grey = [0.8,0.8,0.8];
fill(dategapblocksX,dategapblocksY, grey);
ylim([0 1300])
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
>>>>>>> 18dfc1fa0cdc4fadefafaa1d6da05aff354aa79f
saveas(gca, filename, 'tif')
saveas(gca, filename, 'jpg')
close(figure(8));



% %make a time series!
% figure(8)
% hist(allclickDnum(:,1),77) %77 days between start and end of effort, to get clicks per day.
% ylim([0 1300])
% % xlim([0 0.5])
% %Add grey boxes for no refording effort. Lines at july 27 and october 11 
% dategapblocksX = [735781 735781 735807 735807 735885 735885 735903 735903];%values for bottoms and tops of squares to add [b,t,t,b]
% dategapblocksY = [0 1300 1300 0 0 1300 1300 0];
% hold on
% grey = [0.8,0.8,0.8];
% fill(dategapblocksX,dategapblocksY, grey);
% ylim([0 1300])
% current_day = datenum('Jul 15 2014'); %the date the plot starts
% [Y, M, D, H, MN, S] = datevec(current_day);
% current_day = addtodate(current_day, -D + 1,'day');
% last_day = datenum('Oct 31 2014');
% xlim([current_day last_day]);
% xtick = [current_day];
% xstep_length = 1; %one tick per month
% xstep_unit = 'month';
% while (last_day > current_day)
    % xtick = [xtick addtodate(current_day, xstep_length, xstep_unit)];
    % current_day = addtodate(current_day, xstep_length, xstep_unit);
% end
% ts = gca;
% set(ts,'XTick', xtick,'XTickLabel', datestr(xtick,'mmm yy')); 
% %,'FontSize',14
% set(gca, 'Ticklength', [0 0])
% set(gcf, 'renderer', 'zbuffer'); %removes the exponent from the date  
% title(['Time Series of All Encounters (n = ',strnumenc,')']);
% ylabel('Counts of Clicks per Day')
% xlabel('Date') %Need something here to make this axis pretty with months/dates
% filename = fullfile(GraphDir,['TS_',filedate]);
% saveas(gca, filename, 'tif')
% saveas(gca, filename, 'jpg')
% close(figure(8));


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
SummaryStats = [Q1durClick Q1nDur Q1peakFr Q1ppSig Q1iciEncs;...
    meandurClick meannDur meanpeakFr meanppSignal meaniciEncs;...
    meddurClick mednDur medpeakFr medppSig mediciEncs;...
    Q3durClick Q3nDur Q3peakFr Q3ppSig Q3iciEncs;...
    stddurClick stdnDur stdpeakFr stdppSignal stdiciEncs;...
    skedurClick skenDur skepeakFr skeppSignal skeiciEncs];


filename = fullfile(inDir,['SummaryStats_',filedate]);
save(filename, 'SummaryStats')
xlswrite([filename,'.xls'],SummaryStats)
%Write csv with headers
headers = {'durClick','nDur','peakFr','ppSig','iciEncs'};
csvwrite_with_headers([filename,'.csv'],SummaryStats,headers)


