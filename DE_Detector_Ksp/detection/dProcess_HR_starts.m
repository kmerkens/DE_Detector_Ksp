function [clickTimes,ppSignalVec,durClickVec,bw3dbVec,yNFiltVec,yFiltVec,...
    specClickTfVec, specNoiseTfVec, peakFrVec,yFiltBuffVec,f,deltaEnvVec,nDurVec]...
    = dProcess_HR_starts(fid, wideBandFilter,starts,stops,channel,xfrOffset,...
    specRange,p,hdr,fullFiles,fftWindow,fullLabel)

% Initialize vectors for main detector loop
clickTimes = nan(5E6,2);
ppSignalVec = nan(5E6,1);
durClickVec = nan(5E6,1);
bw3dbVec = [];
yNFiltVec = [];
yFiltVec = cell(5E6,1);
specClickTfVec = cell(5E6,1);
specNoiseTfVec = cell(5E6,1);
peakFrVec = nan(5E6,1);
yFiltBuffVec = cell(5E6,1);
deltaEnvVec = nan(5E6,1);
nDurVec = nan(5E6,1);
f = [];
sIdx = 1;
eIdx = 0;
% Initialize accumulators for noise compensation (Noise model is built
% cumulatively across files).

numStarts = length(starts);
fidOut = fopen(strcat(fullLabel(1:end-1),p.clickAnnotExt),'w+');

for k = 1:numStarts % stepping through using the start/end points
    
    % Filter the data
    wideBandData = dGet_filtered_data(fid,starts(k),stops(k),hdr,...
        wideBandFilter,channel,fullFiles);
    
    % Compute energy of band passed data
    energy = wideBandData.^2;
    % Look for click candidates
    [clicks, noises] = dHighres_click(p, hdr, energy, wideBandData);
    
    %Added in the unusual circumstance where there isn't enough room between
    %multiple clicks to allow taking another noise sample. So, repeat the
    %original noise sample to correspond to the second click.
    if ~isequal(size(clicks,1), size(noises,1));
        numclicks = size(clicks,1);
        noises = repmat(noises,numclicks,1);
    end
    
    if ~ isempty(clicks)
        % if we're in here, it's because we detected one or more possible
        % clicks in the kth segment of data
        % Make sure our click candidates aren't clipped
        validClicks = dPrune_clipping(clicks,p,hdr,wideBandData);
        
        % Look at power spectrum of clicks, and remove those that don't
        % meet peak frequency and bandwidth requirements
        clicks = clicks(validClicks==1,:);
        
        % Compute click parameters to decide if the detection should be kept
        [clickInd,ppSignal,durClick,~,~,yFilt,specClickTf,specNoiseTf,peakFr,yFiltBuff,...
            f,deltaEnv,nDur] = clickParameters(noises,wideBandData,p,...
            fftWindow,xfrOffset,clicks,specRange,hdr);
        
        if ~isempty(clickInd)
            % Write out .cTg file
            [clkStarts,clkEnds] = dProcess_valid_clicks(clicks,clickInd,...
                starts(k),hdr,fidOut,wideBandFilter);
            
            eIdx = sIdx + size(nDur,1)-1;
            clickTimes(sIdx:eIdx,1:2) = [clkStarts,clkEnds];
            ppSignalVec(sIdx:eIdx,1) = ppSignal;
            durClickVec(sIdx:eIdx,1) = durClick;
            % bw3dbVec = [bw3dbVec;bw3db];
            % yNFiltVec = [yNFiltVec;yNFilt];
            yFiltVec(sIdx:eIdx,:)= yFilt';
            specClickTfVec(sIdx:eIdx,1) = specClickTf';
            specNoiseTfVec(sIdx:eIdx,1) = specNoiseTf';
            peakFrVec(sIdx:eIdx,1) = peakFr;
            yFiltBuffVec(sIdx:eIdx,:) = yFiltBuff';
            deltaEnvVec(sIdx:eIdx,1) = deltaEnv;
            nDurVec(sIdx:eIdx,1) = nDur;
            sIdx = eIdx+1;
        end
    end
    if rem(k,1000) == 0
        fprintf('low res period %d of %d complete \n',k,numStarts)
    end
end

fclose(fidOut);
% goodRows = find(~isnan(clickTimes(:,1))==1);
% goodCells = find(cellfun('isempty',yFiltVec)==0);
clickTimes = clickTimes(1:eIdx,:);
ppSignalVec = ppSignalVec(1:eIdx,:);
durClickVec = durClickVec(1:eIdx,:);
yFiltVec = yFiltVec(1:eIdx,:);
specClickTfVec = specClickTfVec(1:eIdx,:);
specNoiseTfVec = specNoiseTfVec(1:eIdx,:);
peakFrVec = peakFrVec(1:eIdx,:);
yFiltBuffVec = yFiltBuffVec(1:eIdx,:);
deltaEnvVec = deltaEnvVec(1:eIdx,:);
nDurVec = nDurVec(1:eIdx,:);
