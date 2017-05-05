
function [medianValues,meanSpecClicks,meanSpecNoises,iciEncs,clickTimesconP,...
    durClickconP, ndur95conP, bw3dbconP, nDurconP, peakFrconP, ppSignalconP,...
    specClickTfconP,specNoiseTfconP, yFiltconP] = plotClickEncounters_posthoc_150310(encounterTimes,...
    clickTimes,ppSignal,durClick,ndur95,bw3db,...
    specClickTf,specNoiseTf,peakFr,nDur,yFilt,hdr,GraphDir,f);
% Generates a set of plots for each encounter, even if they span multiple
% xwavs. Called by cat_click_times.m for plotting after the detector has
% been run.

%,Convert all clicTimes to "real" datenums, relative to baby jesus

clickDnum = clickTimes;

%Loop through the encounters, seeking for clicks that fall within the time
%frame
numEnc = size(encounterTimes,1);
clickCounts = [];
meanSpecClicks = [];
meanSpecNoises = [];
medianValues = [];
iciEncs = [];
%%%Make vectors for saving pruned clicks
clickTimesconP = []; 
durClickconP = [];
ndur95conP = [];
bw3dbconP = [];
% bw10dbconP = [];
nDurconP = [];
peakFrconP = [];
ppSignalconP = [];
specClickTfconP = [];
specNoiseTfconP = [];
yFiltconP = [];
for ne = 1:numEnc
    encStart = encounterTimes(ne,1);
    encStartStr = datestr(encStart);
    encEnd = encounterTimes(ne,2);
    afterStart = find(clickDnum(:,1)> encStart);
    firstafterstart = min(afterStart);
    beforeend = find(clickDnum(:,2)< encEnd);
    lastbeforeend = min(beforeend)-1;
    lastbeforeend = max(beforeend);
    clicksThisEnc =(firstafterstart:lastbeforeend);
    
    if encStart > clickDnum(end,2) 
        display('The rest of the detections are in other files - ending cat_click_times')
        break
    end
    
    if ~isempty(clicksThisEnc) %If there are some clicks...
        
        %Calculate ici
        pos1 = [clickTimes(clicksThisEnc,1);0];
        pos2 = [0;clickTimes(clicksThisEnc,1)];
        iciEncNum = pos1(2:end-1)-pos2(2:end-1);
        iciEncVec = datevec(iciEncNum); %To get the vector
        iciEncSecs = iciEncVec(:,6);
		%161014 If the ICI is very small then the click is probably an echo (or
        %the previous one was), so of those two, remove the one with the
        %smaller amplitude. Sometimes You'll be removing the "good" click,
        %but mostly this will eliminate the echoes. 
        iciTooSmall = find(iciEncSecs < 0.002);
        %First check in the TooSmall list to see if any subsequent clicks
        %are also too close. 
        Alltrashclicks = [];
        newi = 1;
        for i = 1:length(iciTooSmall)
            if i ~= newi
                continue
            end
            SmIciBatch = [];
            SmIciBatch(1) = iciTooSmall(i);
            stepIci = i;
            %And change i to be the last of the batch, so it doesn't
            %repeat part of the batch.
            newi = stepIci+1;
            if i == length(iciTooSmall);
                endclick = max(iciTooSmall)+1;
                stepIci = stepIci + 1;
                SmIciBatch = [SmIciBatch;endclick];
                newi = stepIci+1;
            else 
                while (stepIci+1)>size(iciTooSmall,1)
                    while iciTooSmall(stepIci+1) == iciTooSmall(stepIci)+1
                    stepIci = stepIci + 1;
                    SmIciBatch = [SmIciBatch;iciTooSmall(stepIci)];
                    newi = stepIci+1;
                    end
                end  
            end
            %Now that I have all the icis in this group that are too close,
            %check all of those clicks and the previous one for the highest 
            %amplitude and save that one, remove all the others. 
            if i ~= 1
                PrevClick = iciTooSmall(i) - 1;
                SmIciBatch = [PrevClick; SmIciBatch];
                SmIciBatchPPs = ppSignal(SmIciBatch);
    %             [M,keeperIci] = max(SmIciBatchPPs);
                trashPPs = find(SmIciBatchPPs~=max(SmIciBatchPPs));
                trashclicks = SmIciBatch(trashPPs);
                Alltrashclicks = [Alltrashclicks; trashclicks];
            end
                
            
        end
        %Remove those clicks from further consideration.
        if ~isempty(Alltrashclicks)
            clicksThisEnc(Alltrashclicks) = [];
        end
        
        %Remove the short icis from the overal calculation
        iciEncSecs(iciTooSmall) = [];
		
        %If it's bigger than 0.5 seconds, remove it - there are missed
        %clicks (and that's generous, I could probably use 0.2 seconds or
        %less and still be fine. 
        iciTooBig = find(iciEncSecs > 0.5);
        iciEncSecs(iciTooBig) = [];
        iciEnc = iciEncSecs*1000; %inter-click interval in ms
        iciEncs = [iciEncs; iciEnc]; 

            
        %calculate medians;
        params = {'median peak frequency (kHz)','median ipi (ms)',...
            'median duration (us)','median received level (dB re 1 uPa)',...
            'encounter start','median -3dB BW',...
            'median 95% duration (us)'}; %median center frequency (kHz)
        percentiles = [10 50 90];
        medianValue(1) = prctile(peakFr(clicksThisEnc),50);%calculate median peak frequency
        medianValue(2) = prctile(iciEnc,50);%calculate median inter-pulse interval
        medianValue(3) = prctile(durClick(clicksThisEnc),50);%calculate median duration
		medianValue(8) = prctile(ndur95(clicksThisEnc),50);%calculate median duration       
	    medianValue(4) = prctile(ppSignal(clicksThisEnc),50);%calculate median inter-pulse interval
        %medianValue(5) = prctile(F0Sel,50);%calculate median center frequency
        medianValue(5) = encStart;
		medianValue(6) = prctile(bw3db(clicksThisEnc,3),50); %calculate median -3dB BW
%         medianValue(7) = prctile(bw10db(clicksThisEnc,3),50); %calculate median -10dB BW
        medianValues = [medianValues; medianValue];
        clickCount = sum(clicksThisEnc);%count number of clicks in analysis
        clickCounts = [clickCounts; clickCount];
        maxRL = max(ppSignal(clicksThisEnc));

        %sort spectras for peak frequency and prepare for plotting concetanated
        %spectrogram
        [a b]=sort(peakFr(clicksThisEnc));
        specClickTfThisEnc = specClickTf(firstafterstart:lastbeforeend,1);
        specNoiseTfThisEnc = specNoiseTf(firstafterstart:lastbeforeend,1);

        specSorted=[];
        for c=1:length(b)
            thisspec = cell2mat(specClickTfThisEnc(b(c),:));
            specSorted(c,:)=thisspec;
        end
        
        specSortedNoise = [];
        for c=1:length(b)
            thisspec = cell2mat(specNoiseTfThisEnc(b(c),:));
            specSortedNoise(c,:)=thisspec;
        end
        
%         %%%%%To make a waterfall plot of the spectra
%         waterf = 0;
%         for p = 1:(size(specSorted,1))
%             
%             specplot = specSorted(p,:) + waterf;
%             plot(f,specplot)
%             hold on
%             waterf = waterf + 3;
%         end
        
        
        specSorted=specSorted.';  
        specSortedNoise = specSortedNoise.';

        N=size(specSorted,1)*2;
        %f=0:(fs/2000)/(N/2-1):fs/2000; %this should be loaded, don't
        %recalculate it! Its particular to the (BPF) parameters that were use to
        %run the detector
        datarow=size(specSorted,2);

        %calculate mean spectra for click and noise
        meanSpecClick = mean(specSorted');
        SpecClickplusID = [encStart,meanSpecClick];
        meanSpecClicks = [meanSpecClicks; SpecClickplusID];
        
        %maybe add here a check for repeat noise signals.
        meanSpecNoise=mean(specSortedNoise');
        SpecNoiseplusID = [encStart,meanSpecNoise];
        meanSpecNoises = [meanSpecNoises; SpecNoiseplusID];

%         sep = strfind(pathstr,'\');
%         disk = pathstr(sep(2)+1:length(pathstr));
% 
%         figure('Name', sprintf('%s %s', disk, datestr(encStart)),...
%              'Position',([0,0,1200,800]))

        subplot(3,2,1)
        vec=0:10:300;
        hist(ndur95(clicksThisEnc),vec)
        xlim([0 300])
        xlabel('click duration (us)')
        ylabel('counts')
        text(0.5,0.9,['dur =',num2str(medianValue(8)),' \mus'],'Unit','normalized')

        subplot(3,2,2)
        vec=0:10:1000;
        hist(iciEnc,vec)
        xlim([0 500])
        xlabel('inter-pulse interval (ms)')
        ylabel('counts')
        text(0.5,0.9,['ipi =',num2str(medianValue(2)),' ms'],'Unit','normalized')
        text(0.5,0.8,['ipi count =',num2str(size(iciEnc,1))],'Unit','normalized')

        subplot(3, 2, 3);
        vec=0:1:190;
        hist(peakFr(clicksThisEnc),vec)
        xlim([0 f(end)])
        xlabel('peak frequency (kHz)')
        ylabel('counts')
        text(0.05,0.9,['pfr =',num2str(medianValue(1)),' kHz'],'Unit','normalized')
        %text(0.5,0.8,['cfr =',num2str(medianValue(5)),' kHz'],'Unit','normalized')

        subplot(3,2,4)
        plot(f,meanSpecClick,'LineWidth',2), hold on
        plot(f,meanSpecNoise,':k','LineWidth',1)
        %plot(f,meanSpecNoise,':k','LineWidth',2), hold off
        xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
%         ylim([0 200])
        xlim([0 f(end)])
        %line([120 120], [50 1500],'Color','r','LineWidth',1);
        title(['Mean click spectra, n=',num2str(size(specSorted,2))],'FontWeight','bold')
        text(0.25,0.1,['ppRL =',num2str(medianValue(4))],'Unit','normalized')

        subplot(3,2,5)
        imagesc(1:datarow, f, specSorted); axis xy; colormap(gray)
        %line([0 datarow+0.5],[120 120],'Color','r','LineWidth',1);
        xlabel('Click number'), ylabel('Frequency (kHz)')
        title(['Clicks sorted by peak frequency'],'FontWeight','bold')

        subplot(3,2,6)
        hist(bw3db(clicksThisEnc,3),20)
        xlabel('-3 dB Bandwidth (kHz)')
        ylabel('counts')
        %ylim([0 25])
        %xlim([0 20])
        text(0.3,0.9,['-3dB BW =',num2str(medianValue(6)),' kHz'],'Unit','normalized')
        
%         subplot(3,2,6)
%         hist(bw10db(clicksThisEnc,3),20)
%         xlabel('-10 dB Bandwidth (kHz)')
%         ylabel('counts')
%         %ylim([0 25])
%         %xlim([0 40])
%         text(0.3,0.9,['-10dB BW =',num2str(medianValue(7)),' kHz'],'Unit','normalized')
%        


        seqIdent = sprintf('%s_%s', datestr(encStart,30),'multi');
        filename = fullfile(GraphDir,seqIdent);
        saveas(gca, filename, 'jpg')
        
        close
        
        figure
        plot(f,meanSpecClick,'LineWidth',2), hold on
        plot(f,meanSpecNoise,':k','LineWidth',1)
        %plot(f,meanSpecNoise,':k','LineWidth',2), hold off
        xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
        %ylim([50 125])
        xlim([0 hdr.fs/2000])
        title(['Mean click spectra, n=',num2str(size(specSorted,2))],'FontWeight','bold')
        text(0.05,0.9,['pfr =',num2str(medianValue(1)),' kHz'],'Unit','normalized')

        seqIdent = sprintf('%s_%s', datestr(encStart,30),'spec');
        filename = fullfile(GraphDir,seqIdent);
        saveas(gca, filename, 'jpg')
        saveas(gca, filename, 'tif')

        close
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\

%         %plot time series & spectrogram to check each one. Not saved.  
%         fs = 320000;
%         
%         [c d]=sort(ppSignal,'descend');
% 
%         yFiltClickSorted=[];
%         for i=1:length(d)
%             thisfilt = cell2mat(yFilt(d(i),:));
%             yFiltClickSorted(i,:) = thisfilt;
%         end
% 
%         
%         f=0:(fs/2000)/(N/2-1):fs/2000;
%         s=51;
%         e=300;
%         dd=e-s+1;
%         t=0:(dd/(fs/1000))/(dd-1):dd/(fs/1000);
% 
%         for i=1:size(yFiltClickSorted,1)
%             [Y,F,T,P] = spectrogram(yFiltClickSorted(i,(s:e)),40,39,40,fs);
%             T = T*1000;
%             F = F/1000;
% 
%             subplot(2,1,1), plot(t,yFiltClickSorted(i,(s:e)),'k')
%             ylabel('Amplitude [counts]','fontsize',10,'fontweight','b')
% 
%             subplot(2,1,2), surf(T,F,10*log10(abs(P)),'EdgeColor','none');
%             axis xy; axis tight; colormap(gray); view(0,90);
%             xlabel('Time [ms]','fontsize',10,'fontweight','b')
%             ylabel('Frequency [kHz]','fontsize',10,'fontweight','b');
%             %pause
%         end 




    else
        display(['Oops! There''s no plot for this encounter: ',encStartStr]);
        
    end
	
	%%%Concatenate the pruned clicks for saving
    clickTimesconP = [clickTimesconP;clickTimes(clicksThisEnc,1:2)]; %save to one vector
    durClickconP = [durClickconP;durClick(clicksThisEnc)];
    ndur95conP = [ndur95conP;ndur95(clicksThisEnc)];
    bw3dbconP = [bw3dbconP;bw3db(clicksThisEnc,1:3)];
%     bw10dbconP = [bw10dbconP;bw10db(clicksThisEnc,1:3)];
    nDurconP = [nDurconP; nDur(clicksThisEnc)];
    peakFrconP = [peakFrconP; peakFr(clicksThisEnc)];
    ppSignalconP = [ppSignalconP; ppSignal(clicksThisEnc)];
    specClickTfconP = [specClickTfconP; specClickTf(clicksThisEnc)];
    specNoiseTfconP = [specNoiseTfconP; specNoiseTf(clicksThisEnc)];
    yFiltconP = [yFiltconP; yFilt(clicksThisEnc)];
	
    
end