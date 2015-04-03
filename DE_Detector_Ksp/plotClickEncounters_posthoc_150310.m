
function [medianValues,meanSpecClicks,iciEncs] = plotClickEncounters_posthoc_150310(encounterTimes,clickTimes,ppSignal,...
    durClick,specClickTf,peakFr,nDur,yFilt,hdr,GraphDir,fs)

%,Convert all clicTimes to "real" datenums, relative to baby jesus

clickDnum = clickTimes;

%Loop through the encounters, seeking for clicks that fall within the time
%frame
numEnc = size(encounterTimes,1);
clickCounts = [];
meanSpecClicks = [];
medianValues = [];
iciEncs = [];
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
            'median center frequency (kHz)'};
        percentiles = [10 50 90];
        medianValue(1) = prctile(peakFr(clicksThisEnc),50);%calculate median peak frequency
        medianValue(2) = prctile(iciEnc,50);%calculate median inter-pulse interval
        medianValue(3) = prctile(durClick(clicksThisEnc),50);%calculate median duration
        medianValue(4) = prctile(ppSignal(clicksThisEnc),50);%calculate median inter-pulse interval
        %medianValue(5) = prctile(F0Sel,50);%calculate median center frequency
        medianValue(5) = encStart;
        medianValues = [medianValues; medianValue];
        clickCount = sum(clicksThisEnc);%count number of clicks in analysis
        clickCounts = [clickCounts; clickCount];
        maxRL = max(ppSignal(clicksThisEnc));

        %sort spectras for peak frequency and prepare for plotting concetanated
        %spectrogram
        [a b]=sort(peakFr(clicksThisEnc));

        specSorted=[];
        for c=1:length(b)
            thisspec = cell2mat(specClickTf(b(c),:));
            specSorted(c,:)=thisspec;
        end
        specSorted=specSorted.';

        N=size(specSorted,1)*2;
        f=0:(fs/2000)/(N/2-1):fs/2000;
        datarow=size(specSorted,2);

        %calculate mean spectra for click and noise
        meanSpecClick = mean(specSorted');
        SpecClickplusID = [encStart,meanSpecClick];
        meanSpecClicks = [meanSpecClicks; SpecClickplusID];

        %meanSpecNoise=mean(specNoiseSel);

%         sep = strfind(pathstr,'\');
%         disk = pathstr(sep(2)+1:length(pathstr));
% 
%         figure('Name', sprintf('%s %s', disk, datestr(encStart)),...
%              'Position',([0,0,1200,800]))

        subplot(2, 2, 1);
        vec=0:1:160;
        hist(peakFr(clicksThisEnc),vec)
        xlim([0 fs/2000])
        xlabel('peak frequency (kHz)')
        ylabel('counts')
        text(0.05,0.9,['pfr =',num2str(medianValue(1)),' kHz'],'Unit','normalized')
        %text(0.5,0.8,['cfr =',num2str(medianValue(5)),' kHz'],'Unit','normalized')

        subplot(2,2,2)
        vec=0:10:1000;
        hist(iciEnc,vec)
        xlim([0 1000])
        xlabel('inter-pulse interval (ms)')
        ylabel('counts')
        text(0.5,0.9,['dur =',num2str(medianValue(3)),' \mus'],'Unit','normalized')
        text(0.5,0.8,['ipi =',num2str(medianValue(2)),' ms'],'Unit','normalized')

        subplot(2,2,3)
        plot(f,meanSpecClick,'LineWidth',2), hold on
        %plot(f,meanSpecNoise,':k','LineWidth',2), hold off
        xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
        ylim([50 125])
        xlim([0 fs/2000])
        title(['Mean click spectra, n=',num2str(size(specSorted,2))],'FontWeight','bold')
        text(0.5,0.9,['ppRL =',num2str(medianValue(4))],'Unit','normalized')

        subplot(2,2,4)
        imagesc(1:datarow, f, specSorted); axis xy; colormap(gray)
        xlabel('Click number'), ylabel('Frequency (kHz)')
        title(['Clicks sorted by peak frequency'],'FontWeight','bold')

        seqIdent = sprintf('%s_%s', datestr(encStart,30),'multi');
        filename = fullfile(GraphDir,seqIdent);
        saveas(gca, filename, 'jpg')
        
        close
        
        figure
        plot(f,meanSpecClick,'LineWidth',2), hold on
        %plot(f,meanSpecNoise,':k','LineWidth',2), hold off
        xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
        ylim([50 125])
        xlim([0 fs/2000])
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
    
end