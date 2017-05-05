%Code to combine the .mat files output from cat_click_times.m to get
%overall summary statistics and make plots of the detections from the
%entire deployment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Load data
inDir = 'C:\Users\KMERKENS\Documents\Kogia\DetectorOutput\Hawaii_K_23_01';
GraphDir = 'C:\Users\KMERKENS\Documents\Kogia\DetectorOutput\Hawaii_K_23_01\Final_histograms';

matList = dir(fullfile(inDir,'Hawaii*.mat')); % Add wildcard to match the files you want to process.

fs = 200000;

allclickDnum = [];
alldurClickcon = [];
allnDurcon = [];
allndur95con = [];
allbw3dbcon = [];
% allbw10dbcon = [];
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
        'nDurcon', 'ndur95con','bw3dbcon','peakFrcon','ppSignalcon','specClickTfcon',...
        'specNoiseTfcon','yFiltcon','medianValues','meanSpecClicks','meanSpecNoises',...
        'iciEncs','f')
    
    allclickDnum = [allclickDnum;clickDnum]; %save to one vector
    alldurClickcon = [alldurClickcon;durClickcon];
    allnDurcon = [allnDurcon; nDurcon];
    allndur95con = [allndur95con; ndur95con];
    allbw3dbcon = [allbw3dbcon; bw3dbcon(:,3)];
%     allbw10dbcon = [allbw10dbcon; bw10dbcon(:,3)];
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

save([inDir,'_AllParamsConcat',filedate,'.mat'],...
'f','allclickDnum','alldurClickcon','allndur95con',...
'allbw3dbcon','allnDurcon','allpeakFrcon',...
'allppSignalcon','allspecClickTfcon','allspecNoiseTfcon','allyFiltcon',...
'allmedianValues','allmeanSpecClicks','allmeanSpecNoises','alliciEncs')


% %%%%
% %Want to save everything in a .csv format? Then call this script:
% saveDetecorOutput_170329(inDir,f,allndur95con,allbw3dbcon,...
%     allbw10dbcon,allpeakFrcon,allspecClickTfcon,allspecNoiseTfcon,...
%     alliciEncs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate 25th, median and 75th percentiles for median values, to give some sense
%of width of the histogram spans. 
Q1peakFr = prctile(allpeakFrcon,25);
Q1iciEncs = prctile(alliciEncs,25);
Q1durClick = prctile(alldurClickcon,25);
Q1ndur95 = prctile(allndur95con,25);
Q1bw3db = prctile(allbw3dbcon,25);
% Q1bw10db = prctile(allbw10dbcon,25);
Q1nDur = prctile(allnDurcon,25);
Q1ppSig = prctile(allppSignalcon,25);

medpeakFr = prctile(allpeakFrcon,50);
mediciEncs = prctile(alliciEncs,50);
meddurClick = prctile(alldurClickcon,50);
medndur95 = prctile(allndur95con,50);
medbw3db = prctile(allbw3dbcon,50);
% medbw10db = prctile(allbw10dbcon,50);
mednDur = prctile(allnDurcon,50);
medppSig = prctile(allppSignalcon,50);

Q3peakFr = prctile(allpeakFrcon,75);
Q3iciEncs = prctile(alliciEncs,75);
Q3durClick = prctile(alldurClickcon,75);
Q3ndur95 = prctile(allndur95con,75);
Q3bw3db = prctile(allbw3dbcon,75);
% Q3bw10db = prctile(allbw10dbcon,75);
Q3nDur = prctile(allnDurcon,75);
Q3ppSig = prctile(allppSignalcon,75);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Make plots and save them
% 
% %Click duration - old method
% subplot(2,1,1)
% vec=0:10:400;
% hist(alldurClickcon,vec)
% xlim([0 400])
% line([meddurClick meddurClick], [0 200],'Color','r','LineWidth',1);
% line([Q1durClick Q1durClick], [0 200],'Color','r','LineWidth',1,'LineStyle',':');
% line([Q3durClick Q3durClick], [0 200],'Color','r','LineWidth',1,'LineStyle',':');
% text(0.5,0.9,['25th pctile = ',num2str(Q1durClick),' \musec'],'Unit','normalized','Color','r')
% text(0.5,0.8,['median = ',num2str(meddurClick),' \musec'],'Unit','normalized','Color','r')
% text(0.5,0.7,['75th pctile = ',num2str(Q3durClick),' \musec'],'Unit','normalized','Color','r')
% ylim([0 120])
% title(['Histgram of all click durations - old (\musec) (n = ',strnclicks,')']);
% ylabel('Counts')
% xlabel('Time (\musec)')
% 
%nDur95 = Envelope duration 95%
% subplot(2,1,2)
vec=0:10:500;
hist(allndur95con,vec)
xlim([0 500])
line([medndur95 medndur95], [0 3500],'Color','r','LineWidth',1);
line([Q1ndur95 Q1ndur95], [0 3500],'Color','r','LineWidth',1,'LineStyle',':');
line([Q3ndur95 Q3ndur95], [0 3500],'Color','r','LineWidth',1,'LineStyle',':');
text(0.5,0.9,['25th pctile = ',num2str(Q1ndur95),' \musec'],'Unit','normalized','Color','r')
text(0.5,0.8,['median = ',num2str(medndur95),' \musec'],'Unit','normalized','Color','r')
text(0.5,0.7,['75th pctile = ',num2str(Q3ndur95),' \musec'],'Unit','normalized','Color','r')
%ylim([0 70])
title(['95% (\musec) (n = ',strnclicks,')']);
%ylabel('Counts')
xlabel('Time (\musec)')
filename = fullfile(GraphDir,['Duration_',filedate]);
saveas(gca, filename, 'tif')
saveas(gca, filename, 'jpg')
close


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make plots and save them

% %Click duration
% figure(1)
% hist(alldurClickcon,50)
% line([meddurClick meddurClick], [0 4000],'Color','r','LineWidth',3);
% line([Q1durClick Q1durClick], [0 4000],'Color','r','LineWidth',2,'LineStyle',':');
% line([Q3durClick Q3durClick], [0 4000],'Color','r','LineWidth',2,'LineStyle',':');
% text(0.5,0.9,['25th pctile = ',num2str(Q1durClick),' \musec'],'Unit','normalized','Color','r')
% text(0.5,0.85,['median = ',num2str(meddurClick),' \musec'],'Unit','normalized','Color','r')
% text(0.5,0.8,['75th pctile = ',num2str(Q3durClick),' \musec'],'Unit','normalized','Color','r')
% %ylim([0 400])
% Xlim([0 400])
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


% %PeakFrequency
% figure(3)
% vec=85:1:100;
% hist(allpeakFrcon,vec)
% line([medpeakFr medpeakFr], [0 4000],'Color','r','LineWidth',3);
% line([Q1peakFr Q1peakFr], [0 4000],'Color','r','LineWidth',2,'LineStyle',':');
% line([Q3peakFr Q3peakFr], [0 4000],'Color','r','LineWidth',2,'LineStyle',':');
% text(0.1,0.9,['25th pctile = ',num2str(Q1peakFr,3),' kHz'],'Unit','normalized','Color','r')
% text(0.1,0.85,['median = ',num2str(medpeakFr,3),' kHz'],'Unit','normalized','Color','r')
% text(0.1,0.8,['75th pctile = ',num2str(Q3peakFr,3),' kHz'],'Unit','normalized','Color','r')
% %ylim([0 600])
% xlim([88 100])
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
% 
% 
% %ici per encounter
% %Remove ICIs less than 2 and greater than 500
% remove = find(alliciEncs<2 | alliciEncs>490);
% alliciEncs(remove) = [];
% numicis = size(alliciEncs,1);
% strnicis = num2str(numicis);
% figure(5)
% xbins = 10:20:505;
% hist(alliciEncs,xbins)
% % hist(alliciEncs,50)
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
% %-3 dB Bandwidth
% figure(5)
% xbins = 0:1:30;
% hist(allbw3dbcon,xbins)
% xlim([0 30])
% title(['Histgram of all -3dB Bandwidths (n = ',strnclicks,')']);
% ylabel('Counts')
% xlabel('-3dB Bandwidth (kHz)')
% set(get(gca,'child'),'FaceColor','k','EdgeColor','w');
% filename = fullfile(GraphDir,['3dBBW_',filedate]);
% saveas(gca, filename, 'tif')
% saveas(gca, filename, 'jpg')
% saveas(gca, filename, 'fig')
% close(figure(5));
% 
% % %-10 dB Bandwidth
% % figure(5)
% % xbins = 0:2:80;
% % hist(allbw10dbcon,xbins)
% % xlim([0 80])
% % title(['Histgram of all -10dB Bandwidths (n = ',strnclicks,')']);
% % ylabel('Counts')
% % xlabel('-10dB Bandwidth (kHz)')
% % set(get(gca,'child'),'FaceColor','k','EdgeColor','w');
% % filename = fullfile(GraphDir,['10dBBW_',filedate]);
% % saveas(gca, filename, 'tif')
% % saveas(gca, filename, 'jpg')
% % saveas(gca, filename, 'fig')
% % close(figure(5));




% %Next -plot the median values
% numMeds = size(allmedianValues,1);
% strnMeds = num2str(numMeds);
% titlecell = {'Peak Frequency', 'Inter-click-interval','Click Duration',...
%     'Peak-to-peak amplitude';'(kHz)','(ms)','(\musec)', '(dB)';...
%     'Frequency', 'Time','Time','Amplitude'};
% figure(6)
% for p = 1:4
%     subplot(2,2,p)
%     hist(allmedianValues(:,p),20);
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
% 

% %Then plot the mean spectra - could overlay with different colors
% numSpecs = size(allmeanSpecClicks,1);
% strnSpecs = num2str(numSpecs);
% %Make frequency axis
% numFreqBins = (size(allmeanSpecClicks,2))-1;
% %steps = (fs/2)/(numFreqBins-1);
% %freqs = (0:steps:(fs/2))/1000;
% freqs = f;
% figure(7)
% for p = 1:numSpecs
%     %plot(freqs,allmeanSpecClicks(p,2:end), 'Color',rand(1,3));
%     plot(freqs,allmeanSpecClicks(p,2:end), 'Color','k');
%     hold on
%     plot(freqs,allmeanSpecNoises(p,2:end), 'Color',[0.7, 0.7, 0.7], 'LineStyle',':');
% end
% legend('mean click','mean noise','Location','southwest')
% title(['Mean Spectrum of Each Encounter (n = ',strnumenc,')']);
% xlabel('Frequency (kHz)')
% ylabel('Amplitude (dB)')
% filename = fullfile(GraphDir,['MeanSpecPerEncounter',filedate]);
% saveas(gca, filename, 'tif')
% saveas(gca, filename, 'jpg')
% close(figure(7));
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Then combine all spectra and calculate one mean, plot with the mean noise
%from the first file.
%First, calculate the mean. start by looping through all the entries in the
%cell array and saving those to a non-cell matrix
numspecClick = size(allspecClickTfcon,1);
numspecNoise = size(allspecNoiseTfcon,1);
concatspecs = [];
concatspecsN = [];
for s = 1:numspecClick
        concatspecs = [concatspecs;allspecClickTfcon{s,1}'];
end
grandmeanSpec = mean(concatspecs);


for s = 1:numspecNoise
        concatspecsN = [concatspecsN;allspecNoiseTfcon{s,1}'];
end
%Get unique noise spectra (because some/many are repeats)
concatspecsNU = unique(concatspecsN,'rows');
grandmeanSpecN = mean(concatspecsNU);

%Make frequency axis
numFreqBins = (size(allmeanSpecClicks,2))-1;
freqs = f;

    
figure(8)
plot(freqs,grandmeanSpec(1,1:end), 'Color','k','LineWidth',1);
hold on
plot(freqs,grandmeanSpecN(1,1:end), 'Color',[0.7, 0.7, 0.7], 'LineWidth',1);
% plot(freqs,allmeanSpecNoises(1,2:end), 'Color',[0.7, 0.7, 0.7], 'LineWidth',1);
% xlim([0 100]);
xlim([0 170]);
ylim([145 185]);
legend('mean click','mean noise','Location','southwest')
title(['Mean Spectrum of all Clicks (n = ',num2str(numspecClick),')']);
xlabel('Frequency (kHz)')
ylabel('Amplitude (dB)')
filename = fullfile(GraphDir,['MeanSpecGrand',filedate]);
saveas(gca, filename, 'tif')
saveas(gca, filename, 'jpg')
close(figure(8));


%Make it pretty for publications
%Normalize to max value
prenorm = grandmeanSpec(1,1:end);
maxfreq = max(prenorm);
normdbs = prenorm-maxfreq;
prenormnoise = grandmeanSpecN(1,1:end);
normnoisedbs = prenormnoise-maxfreq;
%Truncate at 20kHz and 190kHz (186 for Janik)
toolowfreq = find(freqs < 20);
normdbs(toolowfreq) = [];
normnoisedbs(toolowfreq) = [];
plotfreqs = freqs;
plotfreqs(toolowfreq) = [];
toohighfreq = find(plotfreqs > 186);
normdbs(toohighfreq) = [];
normnoisedbs(toohighfreq) = [];
plotfreqs(toohighfreq) = [];


figure(9)
plot(plotfreqs,normdbs, 'Color','k','LineWidth',2);
hold on
plot(plotfreqs,normnoisedbs, 'Color',[0.7, 0.7, 0.7],...
    'LineWidth',2);
xlim([0 200]);
set(gca,'XTick',[0,40,80,120,160,200],'FontSize',18);
xlabel('Frequency (kHz)','FontSize',18);
ylim([-30 3]);
set(gca,'YTick',[-30,-15,0],'FontSize',18);
ylabel('Relative Spectral Level (dB)','FontSize',18);
%set shape/size
set(gcf,'PaperUnits', 'inches','PaperPosition', [0 0 6 6]);


filename = fullfile(GraphDir,['MeanSpecGrand_forPub',filedate]);
print('-dtiff',filename)
%print('-djpeg', filename)
print('-dpng', filename,'-r600')
%print('-deps', filename,'-r200')
saveas(gca, filename, 'fig')
close(figure(9));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% % % %make a time series!
% % % figure(9)
% % hist(allclickDnum(:,1),77) %77 days between start and end of effort, to get clicks per day.
% % ylim([0 1300])
% % % xlim([0 0.5])
% % %Add grey boxes for no refording effort. Lines at july 27 and october 11 
% % dategapblocksX = [735781 735781 735807 735807 735885 735885 735903 735903];%values for bottoms and tops of squares to add [b,t,t,b]
% % dategapblocksY = [0 1300 1300 0 0 1300 1300 0];
% % hold on
% % grey = [0.8,0.8,0.8];
% % fill(dategapblocksX,dategapblocksY, grey);
% % ylim([0 1300])
% % current_day = datenum('Jul 15 2014'); %the date the plot starts
% % [Y, M, D, H, MN, S] = datevec(current_day);
% % current_day = addtodate(current_day, -D + 1,'day');
% % last_day = datenum('Oct 31 2014');
% % xlim([current_day last_day]);
% % xtick = [current_day];
% % xstep_length = 1; %one tick per month
% % xstep_unit = 'month';
% % while (last_day > current_day)
% %     xtick = [xtick addtodate(current_day, xstep_length, xstep_unit)];
% %     current_day = addtodate(current_day, xstep_length, xstep_unit);
% % end
% % ts = gca;
% % set(ts,'XTick', xtick,'XTickLabel', datestr(xtick,'mmm yy')); 
% % %,'FontSize',14
% % set(gca, 'Ticklength', [0 0])
% % set(gcf, 'renderer', 'zbuffer'); %removes the exponent from the date  
% % title(['Time Series of All Encounters (n = ',strnumenc,')']);
% % ylabel('Counts of Clicks per Day')
% % xlabel('Date') %Need something here to make this axis pretty with months/dates
% % filename = fullfile(GraphDir,['TS_',filedate]);
% % saveas(gca, filename, 'tif')
% % saveas(gca, filename, 'jpg')
% % close(figure(8));
% % 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate some summary stats for each parameter

%Averages 
meandurClick = mean(alldurClickcon);
meannDur = mean(allnDurcon);
meanndur95 = mean(allndur95con);
meanbw3db = nanmean(allbw3dbcon);
% meanbw10db = mean(allbw10dbcon);
meanpeakFr = mean(allpeakFrcon);
meanppSignal = mean(allppSignalcon);
%meanspecClickTf = mean(allspecClickTfcon);
meaniciEncs = mean(alliciEncs);

%Standard Deviation
stddurClick = std(alldurClickcon);
stdnDur = std(allnDurcon);
stdndur95 = std(allndur95con);
stdbw3db = std(allbw3dbcon); %might need to add parameter 'omitnan'
% stdbw10db = std(allbw10dbcon);
stdpeakFr = std(allpeakFrcon);
stdppSignal = std(allppSignalcon);
%stdspecClickTf = std(allspecClickTfcon);
stdiciEncs = std(alliciEncs);

%medians (previously calculated)
meddurClick;
mednDur;
medndur95;
medbw3db;
% medbw10db;
medpeakFr;
medppSig;
mediciEncs;

%kurtosis

% %Skewness
% skedurClick = skewness(alldurClickcon);
% skenDur = skewness(allnDurcon);
% skendur95 = skewness(allndur95con);
% skebw3db = skewness(allbw3dbcon);
% % skebw10db = skewness(allbw10dbcon);
% skepeakFr = skewness(allpeakFrcon);
% skeppSignal = skewness(allppSignalcon);
% %skespecClickTf = skewness(allspecClickTfcon);
% skeiciEncs = skewness(alliciEncs);

%Make one table, save it as .mat and .xls 
SummaryStats = [Q1durClick Q1nDur Q1ndur95 Q1bw3db  Q1peakFr Q1ppSig Q1iciEncs;...
    meandurClick meannDur meanndur95 meanbw3db  meanpeakFr meanppSignal meaniciEncs;...
    meddurClick mednDur medndur95 medbw3db  medpeakFr medppSig mediciEncs;...
    Q3durClick Q3nDur Q3ndur95 Q3bw3db  Q3peakFr Q3ppSig Q3iciEncs;...
    stddurClick stdnDur stdndur95 stdbw3db  stdpeakFr stdppSignal stdiciEncs];
%     skedurClick skenDur skendur95 skebw3db  skepeakFr skeppSignal skeiciEncs];


filename = fullfile(inDir,['SummaryStats_',filedate]);
save(filename, 'SummaryStats')
xlswrite([filename,'.xls'],SummaryStats)
%Write csv with headers
headers = {'durClick','nDur','ndur95','bw3db','peakFr','ppSig','iciEncs'};
csvwrite_with_headers([filename,'.csv'],SummaryStats,headers)
