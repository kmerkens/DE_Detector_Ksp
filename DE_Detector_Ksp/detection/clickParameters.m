function [clickInd,ppSignal,durClick,dur95usec,bw3db,yNFilt,yFilt,specClickTf,...
    specNoiseTf,peakFr,yFiltBuff,f,deltaEnv,nDur] = clickParameters(noises,wideBandData,p,fftWindow,...
    PtfN,clicks,specRange,hdr)

%Take timeseries out of existing file, convert from normalized data to
%counts
%1) calculate spectral received levels RL for click and preceding noise:
%calculate spectra, account for bin width to reach dB re counts^2/Hz,
%add transfer function, compute peak frequency and bandwidth
%2) calculate RLpp at peak frequency: find min & max value of timeseries,
%convert to dB, add transfer function value of peak frequency (should come
%out to be about 9dB lower than value of spectra at peak frequency)
%3) Prune out clicks that don't fall in expected peak frequency, 3dB
%bandwidth/duration range, or which are not high enough amplitude
%(ppSignal)
% ** There's code in here to compute a noise spectrum alongside the click
% spectrum. It should at least get you started if you want that sort of
% thing.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize variables

N = length(fftWindow);
ppSignal = zeros(size(clicks,1),1);
durClick =  zeros(size(clicks,1),1);
dur95usec = zeros(size(clicks,1),1);
bw3db = nan(size(clicks,1),3);
bw10db = zeros(size(clicks,1),3);
yNFilt = cell(size(clicks,1),1); 
yFilt = cell(size(clicks,1),1);
zerosvec = zeros(1,300);
yFilt(:) = {zerosvec};
specClickTf = cell(size(clicks,1),1);
yFiltBuff = cell(size(clicks,1),1);
specNoiseTf = cell(size(clicks,1),1);
yNFiltBuff = cell(size(clicks,1),1);
peakFr = zeros(size(clicks,1),1);
cDLims = ceil([p.minClick_us, p.maxClick_us]./(hdr.fs/1e6));
cDLims95 = ceil([p.minClick_us, p.maxClick95_us]./(hdr.fs/1e6));
envDurLim = ceil(p.delphClickDurLims./(hdr.fs/1e6));
nDur = zeros(size(clicks,1),1);
deltaEnv = zeros(size(clicks,1),1);

f = 0:((hdr.fs/2)/1000)/((N/2)-1):((hdr.fs/2)/1000);
f = f(specRange);

buffVal = hdr.fs*.00025; % Add small buffer, here, I want .25 ms, so computing how many samples to use.
buffValBefore = hdr.fs*.00001; %adding 10us buffer before
buffValAfter = hdr.fs*.00002; %adding 20us buffer after
%buffVal = buffVal * 4;
validClicks = ones(size(ppSignal));


% % concatonnate vector of noise
% 	for itr = 1:min([30,size(noises,1)])
%         nStart = noises(itr,1);
%         nEnd = min([noises(itr,2),nStart+580]);
%         yNFilt = [yNFilt,wideBandData(nStart:nEnd)];
%     end
%     noise = yNFilt*2^14; % convert to counts

for c = 1:size(clicks,1)
   % Pull out band passed click and noise timeseries
%     yFiltBuff{c} = wideBandData(max(clicks(c,1)-buffVal,1):min(clicks(c,2)+buffVal,size(wideBandData,2)));
%     yNFiltBuff{c} = wideBandData(max(noises(c,1)):min(noises(c,2)+buffVal,size(wideBandData,2)));
    yFiltBuff{c} = wideBandData(floor(max(clicks(c,1)-buffValBefore,1)):ceil(min(clicks(c,2)+buffValAfter,size(wideBandData,2))));
    yNFiltBuff{c} = wideBandData(floor(max(noises(c,1))):ceil(min(noises(c,2)+buffValAfter,size(wideBandData,2))));
    yFiltLength = clicks(c,2)-clicks(c,1)+1;
    yNFiltLength = noises(c,2)-noises(c,1)+1;
    yFilt{c,1}(1:yFiltLength) = wideBandData(clicks(c,1):clicks(c,2)); %changed to only extract portion of bandwidth allowed through BPF
    yNFilt{c,1}(1:yNFiltLength) = wideBandData(noises(c,1):noises(c,2));
    %convert  timeseries into counts
    if strcmp(hdr.fType, 'xwav')
        click = yFilt{c}*2^14;
        clickBuff = yFiltBuff{c}*2^14;
        noise = yNFilt{c}*2^14;
        noiseBuff = yNFiltBuff{c}*2^14;
    else
        click = yFilt{c}*2^15; % array needs 2^15 to convert into counts. 
        % Unclear what the cause of this is.
        clickBuff = yFiltBuff{c}*2^15;
        noise = yNFilt{c}*2^15;
        noiseBuff = yNFiltBuff{c}*2^15;
    end
    
    % Compute click spectrum
    winLength = length(clickBuff);
    %winLength = length(click);
    wind = hann(winLength);
    %wClick = zeros(1,N);
    wClick(1:winLength) = clickBuff.*wind';
    %wClick(1:winLength) = clickBuff.*wind.'; %KPM for two vectors it seems
    %that whether the second . is there or not does not matter, because the 
    %type of transpose doesn't matter. 
    %wClick(1:winLength) = click.*wind.';
    spClick = 20*log10(abs(fft(wClick,N)));
    
    % Compute noise spectrum
    %%%karlis
    if length(clickBuff) < length(noiseBuff);
        noiseBuff = noiseBuff(1:length(clickBuff));%make it the same length as the click
    else
        %display('Uh oh! The lengths of the click and noise are not right!')
        validClicks(c) = 0; %remove this click/noise pair from analysis
        continue
    end
    
%     winNLength = length(noiseBuff);
    winNLength = length(clickBuff); %make it the same length as the click        
    %winNLength = length(noise);
    windN = hann(winNLength);
    %wNoise = zeros(1,N);
    wNoise(1:winNLength) = noiseBuff.*windN';
    %wNoise(1:winNLength) = noiseBuff.*windN.';%KPM I don't think that second .
    %should be there after wind
    %wNoise(1:winNLength) = noise.*windN.';
    spNoise = 20*log10(abs(fft(wNoise,N)));
    %spNoise = fastsmooth(20*log10(abs(fft(wNoise,N))),15,1,1); %smooth is prettier
    
    
%     %kaits
%     windNoise = hann(N);
%     wNoise = [];
%     for itr1 = 1:1:floor(length(noise)/N)
%         wNoise(:,itr1) = noise(1,((itr1-1)*N)+1:((itr1-1)*N)+N).*windNoise.';
%     end
%     spNoise = fastsmooth(mean(20*log10(abs(fft(wNoise,N))),2),15,1,1)';
%      
    % account for bin width
    sub = 10*log10(hdr.fs/N);
    spClickSub = spClick-sub;
    spNoiseSub = spNoise-sub;
    
    %reduce data to first half of spectra
    spClickSub = spClickSub(:,1:N/2);
    spNoiseSub = spNoiseSub(:,1:N/2);
    
    
%     f_full = 0:((hdr.fs/2)/1000)/((N/2)-1):((hdr.fs/2)/1000);
%     subplot(2,1,1)
%     plot(f_full, spClickSub);
%     hold on; 
%     plot(f_full,spNoiseSub,'k:');
%     
    
    specClickTf{c} = spClickSub(specRange)'+PtfN;
	specNoiseTf{c} = spNoiseSub(specRange)'+PtfN;
    
    %     plot(wClick)
%     hold on
%     plot(wNoise,'k');
%     close
%     
    %%%%Added to compare click/noise spectra
    
%     %subplot(2,1,2)
%     plot(f, specClickTf{c});
%     hold on; 
%     plot(f,specNoiseTf{c},'k:');
%     close

    %%%%%%%%%%%%%Added to compare effects of adding tf to spectrum
%     woPtfN{c} = (spClickSub(specRange));
%     plot(f,woPtfN{c})
%     hold on
%     plot(f,specClickTf{c}, 'k')
%     
%     [valMx1, posMx1] = max(woPtfN{c}(1:end-1));
%     peakFr1 = f(posMx1)
%     
%     [valMx2, posMx2] = max(specClickTf{c}(1:end-1));
%     peakFr2 = f(posMx2)
%    
%     
%     close
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % calculate peak click frequency
    % max value in the first half samples of the spectrogram
    
    [valMx, posMx] = max(specClickTf{c}(1:end-1)); % ignore last point - bandpass issue
    peakFr(c) = f(posMx); %peak frequency in kHz
    
    if peakFr(c) < p.cutPeakBelowKHz || peakFr(c) > p.cutPeakAboveKHz
        validClicks(c) = 0;
        %plot(f(1:end-1),specClickTf{c}(1:end-1))
        continue
    end
    
%     %if peakFr(c) > 140; %make a plot of the spectrum to check what's up 
%     %with these really high freq signals
%          plot(f(1:end-1),specClickTf{c}(1:end-1))
%     %end

    




    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calculate RLpp at peak frequency: find min/max value of timeseries,
    %convert to dB, add transfer function value of peak frequency (should come
    %out to be about 9dB lower than value of spectra at peak frequency)
    
    % find lowest and highest number in timeseries (counts) and add those
    high = max(yFilt{c}.');
    low = min(yFilt{c}.');
    ppCount = high+abs(low);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calculate dB value of counts and add transfer function value at peak
    %frequency to get ppSignal (dB re 1uPa)
    P = 20*log10(ppCount);
    
    peakLow=floor(peakFr(c));
    if peakLow == (hdr.fs/2)/1000
        fLow = N/2;
    else
        fLow=find(f>peakLow);
    end
    
    %add PtfN transfer function at peak frequency to P
    tfPeak = PtfN(fLow(1));
    ppSignal(c) = P+tfPeak;
    
    if ppSignal(c)< p.ppThresh
        validClicks(c) = 0;
        continue
    end
   
   
    %%%%%%%%%%%%%%%%%
    % calculate click envelope (code & concept from SBP 2014):
    % pre_env = hilbert(click);
    % env = sqrt((real(pre_env)).^2+(imag(pre_env)).^2); %Au 1993, S.178, equation 9-4
%     env = abs(hilbert(click));
    env1 = abs(hilbert(clickBuff));                                              
    
    %calculate energy duration over x% energy(normalize to 0:1)
    env2 = env1 - min(env1);
    env3 = env2/max(env2);
    %determine if the slope of the envelope is positive or negative
    %above x% energy
    aboveThr = find(env3>=p.energyThr);
    direction = nan(1,length(aboveThr));
    for a = 1:length(aboveThr)
        if aboveThr(a)>1 && aboveThr(a)<length(env3)
            % if it's not the first or last element fo the envelope, then
            % -1 is for negative slope, +1 is for + slope
            delta = env3(aboveThr(a)+1)-env3(aboveThr(a));
            if delta>=0
                direction(a) = 1;
            else
                direction(a) = -1;
            end
        elseif aboveThr(a) == 1
            % if you're looking at the first element of the envelope
            % above the energy threshold, consider slope to be negative
            direction(a) = -1;
        else  % if you're looking at the last element of the envelope
            % above the energy threshold, consider slope to be positive
            direction(a) = 1;
        end
    end
    
%     %find the first value above threshold with positive slope and find
%     %the last above with negative slope
%     lowIdx = aboveThr(find(direction,1,'first'));
%     negative = find(direction==-1);
%     if isempty(negative)
%         highIdx = aboveThr(end);
%     else
%         highIdx = aboveThr(negative(end));
%     end
%     nDur(c,1) = highIdx - lowIdx + 1;
    
%     %Remove clicks that are too long
%     if nDur(c)>(p.delphClickDurLims(2))
%         validClicks(c) = 0;
%         continue
%     end
%     %Remove clicks that are too short
%     if nDur(c)<(p.delphClickDurLims(1))
%         validClicks(c) = 0;
%         continue
%     end
    
    %compare maximum first half of points with second half.
%     halves = ceil(nDur(c,1)/2);   
%     env1stmax = max(env3(lowIdx:min([lowIdx+halves,length(env3)])));
%     env2ndmax = max(env3(min([lowIdx+(halves)+1,length(env3)]):end));
%     deltaEnv(c,1) = env1stmax-env2ndmax;
%     
%      if deltaEnv(c) < p.dEvLims(1)
%         validClicks(c) = 0;
%         continue
%      end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %New section to calculate the duration of the click using 97% of of
     %the envelope as the metric, sensu madsen et al 2005 and 2004,
     %etc. That means looking from 1.5% to 98.5%

     %Try making cumulative energy plot. 
     %Standardize out of the total energy
     
     %Then sum and normalize to the max  
     totenvenergy = sum(env1);
     env4 = env1/totenvenergy;
     clear('envcum')
     for e = 2:size(env4,2)
        envcum(1) = 0;
        envcum(e) = envcum(e-1)+env4(e-1);
        if e == size(env4,2)
            envcum(e+1) = envcum(e) + env4(e);
        end
     end
%      %Locate the ends of the 97% range
%      durStart = 0.015;
%      durEnd = 0.985;
%      afterStart = find(envcum<=durStart,1,'first'); 
%      beforeEnd = find(envcum>=durEnd,1,'first');
%      dur97cts = beforeEnd - afterStart+1;
%      dur97usec1 = dur97cts/(hdr.fs/1e6); %just to be able to see it while testing
%      dur97usec(c) = dur97cts/(hdr.fs/1e6);
     
     %%Try for 95%
     durStart95 = 0.025;
     durEnd95 = 0.975;
     afterStart95 = find(envcum<=durStart95,1,'first'); 
     beforeEnd95 = find(envcum>=durEnd95,1,'first');
     dur95cts = beforeEnd95 - afterStart95+1;
     
     dur95usec1 = dur95cts/(hdr.fs/1e6); %just to be able to see it while testing
     dur95usec(c) = dur95cts/(hdr.fs/1e6);
     %Only save durations less than 500 us, or whatever is specified in the
     %HR settings
     if dur95usec(c) > p.maxClick95_us
         validClicks(c) = 0;
         continue
     end

    %Remove clicks that are too short
    if dur95usec(c)<(p.minClick_us)
        validClicks(c) = 0;
        continue
    end
    
%     %Test to see about what works better in a noisy environment (can't
%     %narrow BPF)
%     %%Try for 80%
%      durStart80 = 0.1;
%      durEnd80 = 0.9;
%      afterStart80 = find(envcum<=durStart80,1,'first'); 
%      beforeEnd80 = find(envcum>=durEnd80,1,'first');
%      dur80cts = beforeEnd80 - afterStart80+1;
%      
%      dur80usec1 = dur80cts/(hdr.fs/1e6); %just to be able to see it while testing
%      dur80usec(c) = dur80cts/(hdr.fs/1e6);
     
%      %Check to see how much the extra buffer might be influencing the total
%      %duration of the click
%      figure(1)
% %      subplot(2,1,1)
%      plot(clickBuff)
%      hold on
%      plot(env1,'r')
%      line([afterStart80 afterStart80], [min(clickBuff) max(clickBuff)],'Color','k','LineWidth',1);
%      line([beforeEnd80 beforeEnd80], [min(clickBuff) max(clickBuff)],'Color','k','LineWidth',1);
%      
%      subplot(2,1,2)
%      plot(clickBuff(1,1:150))
%      
     %check to see where click is within the segment
%      subplot(2,1,1)
%      plot(wideBandData)
%      hold on
%      line([clicks(c,1) clicks(c,1)], [min(wideBandData) max(wideBandData)],'Color','r','LineWidth',1);
%      line([clicks(c,2) clicks(c,2)], [min(wideBandData) max(wideBandData)],'Color','r','LineWidth',1);
%      
%      subplot(2,1,2)
%      startshortplot = clicks(c,1)-100;
%      endshortplot = clicks(c,2)+100;
%      plotseg = wideBandData(1,startshortplot:endshortplot);
%      plot(plotseg);
%      line([100 100], [min(wideBandData) max(wideBandData)],'Color','r','LineWidth',1);
%      line([size(plotseg,2)-100 size(plotseg,2)-100], [min(wideBandData) max(wideBandData)],'Color','r','LineWidth',1);
%      
%      close(figure(1))


    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %Something to assess "shape" of time series - check for "teardrop"
%     %kogia shape - if the number of samples after the peak is larger than
%     %from before. Two thresholds to set before: the bigenv (big envelope),
%     %and the propthresh 
%     %ONLY USE when you want to keep the BEST, PRETTIEST, CLOSEST TO ON AXIS
%     %clicks, like when you want an "ideal" data set, or are comparing
%     %with other, similar species, like Dall's
%     
%     bigenv = 0.01;
%     overthresh = find(env>0.1);
%     numover = size(overthresh,2);
%     smaller = overthresh<(find(env==1));
%     numsmaller = sum(smaller);
%     propsmaller(c) = numsmaller/numover;
%     propthresh = 0.4;
%     
%      if propsmaller(c) > propthresh
%         validClicks(c) = 0;
%         continue
%     end
%     
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate duration
    durClick(c) = clicks(c,2)-clicks(c,1);
    
    if durClick(c) > cDLims95(2)
        validClicks(c) = 0;
        continue
    end
    
    
    
    
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calculate bandwidth
    %-3dB bandwidth
    %calculation of -3dB bandwidth - amplitude associated with the halfpower points of a pressure pulse (see Au 1993, p.118);
    low = valMx-3; %p1/2power = 10log(p^2max/2) = 20log(pmax)-3dB = 0.707*pmax; 1/10^(3/20)=0.707
    %walk along spectrogram until low is reached on either side
%    slopeup=fliplr(specClickTf(c,1:posMx)); Use this if the spectra are
%    %matricies, otherwise use the one below, with flipud, if they're
%    %vectors in cell arrays. 
    slopeup=flipud(specClickTf{c}(1:posMx));

    slopedown=specClickTf{c}(posMx:floor(length(specClickTf{c})));
    for e3dB=1:length(slopeup)
        if slopeup(e3dB)<low %stop at value < -3dB: point of lowest frequency
            break
        end
    end
    for o3dB=1:length(slopedown)
        if slopedown(o3dB)<low %stop at value < -3dB: point of highest frequency
            break
        end
    end
    
%     %calculation from spectrogram -> from 0 to 100kHz in 256 steps (FFT=512)
%     high3dB = (hdr.fs/(2*1000))*((posMx+o3dB)/(length(specClickTf{c}))); %-3dB highest frequency in kHz
%     low3dB = (hdr.fs/(2*1000))*(posMx-e3dB)/(length(specClickTf{c})); %-3dB lowest frequency in kHz
%     bw3 = high3dB-low3dB;
    
    %Alternative method - use f vector previously determined:
    highbin = posMx+o3dB;
    %Add something to remove values that are above the nyquist. bw3db is a
    %vector of NaNs to start with, so in this case we just skip the part of
    %saving those numbers and leave the NaNs.
    if highbin > length(f)
        continue
    else
        high3dB = f(highbin);
        lowbin = posMx-e3dB;
        if isequal(lowbin, 0)
            lowbin = 1;
        end
        low3dB = f(lowbin);
        bw3 = high3dB-low3dB;
        
        bw3db(c,:)= [low3dB, high3dB, bw3]; 
    end
    
    
    
    
    %%%%%
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%%Useless to calculate -10dB BW for clicks near 100 khz
%%%%%%%%%%%%%%%%%%%%%%%%%



% validClicks = ones(size(ppSignal));
% 
% % Check parameter values for each click
% for idx = 1:length(ppSignal)
%     tfVec = [deltaEnv(idx) < p.dEvLims(1);...
%              peakFr(idx) < p.cutPeakBelowKHz;...
%              peakFr(idx) > p.cutPeakAboveKHz;...
%              nDur(idx)>  (envDurLim(2));...
%              nDur(idx)<  (envDurLim(1));...
%              durClick(idx) > cDLims(2)];
% %          plot(yFiltBuff{idx})
% %          title(sum(tfVec))
% %          1;
%     if ppSignal(idx)< p.ppThresh
%         validClicks(idx) = 0; 
%     elseif sum(tfVec)>0   
%         validClicks(idx) = 0; 
%     end
%     
% end
clickInd = find(validClicks == 1);
% throw out clicks that don't fall in desired ranges
ppSignal = ppSignal(clickInd,:);
durClick =  durClick(clickInd,:);
dur95usec = dur95usec(clickInd,:);
bw3db = bw3db(clickInd,:);
% frames = frames{clickInd};
% yFilt = {yFilt{clickInd}};
yFilt = yFilt(clickInd);
yFiltBuff = yFiltBuff(clickInd);
specClickTf = specClickTf(clickInd);
specNoiseTf = specNoiseTf(clickInd);
peakFr = peakFr(clickInd,:);
% yNFilt = {yNFilt};
deltaEnv = deltaEnv(clickInd,:);
nDur = nDur(clickInd,:);
