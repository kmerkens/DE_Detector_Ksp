function parametersHR = dLoad_HRsettings

%%% Filter and FFT params %%
parametersHR.bpRanges = [40000,99000]; % Bandpass filter params in Hz [min,max]
parametersHR.frameLengthUs = 1200; % For fft computation
parametersHR.overlap = .5; % FFT overlap (in decimal, not percent form)
parametersHR.chan = 1; % which channel do you want to look at?
parametersHR.clipThreshold = .80;%  Normalized clipping threshold btwn 0 and 1.  If empty, 
% assumes no clipping. %Changed from 0.98 150731


%%% Recieved level threshold params %%%
%parametersHR.ppThresh = 100;% minimum  RL threshold - dB peak to peak.
parametersHR.ppThresh = 80;% lowered with new filter 150629 
%parametersHR.ppThresh = 30; %Adjusted for having no tf.
parametersHR.countThresh = 500000; % Keep consistent with Lo-res for predictability.
% Can be higher than low res, but not lower!
% Keep count threshold less than equivalent pp threshold. 
%   dBs = 10*log10(abs(fft(counts *2^14))) - 10*log10(fs/(length(fftWindow)))...
%            + transfer function
% note: array uses 2^15

%%% Envelope params %%%
parametersHR.energyThr = 0.3; % n-percent energy threshold for envelope duration
parametersHR.dEvLims = [-.4,.9];  % [min,max] Envelope energy distribution comparing 
% first half to second half of high energy envelope of click. If there is
% more energy in the first half of the click (dolphin) dEv >0, If it's more
% in the second half (boats?) dEv<0. If it's about the same (beaked whale)
% dEnv ~= 0 , but still allow a range...
parametersHR.delphClickDurLims = [15,30];% [min,max] duration in microsec 
% allowed for high energy envelope of click


%%% Other pruning params %%%
parametersHR.cutPeakBelowKHz = 80; % discard click if peak frequency below X kHz
parametersHR.cutPeakAboveKHz = 99.9; % discard click if peak frequency above Y kHz 
parametersHR.minClick_us = 25;% Minimum duration of a click in us 
parametersHR.maxClick_us = 1000; % Max duration of a click including echos
% parametersHR.maxNeighbor = 1; % max time in seconds allowed between neighboring 
% clicks. Clicks that are far from neighbors can be rejected using this parameter,
% good for dolphins in noisy environments because lone clicks or pairs of
% clicks are likely false positives
parametersHR.maxNeighbor = 2; %Increased, to get faint kogia detections. 


parametersHR.mergeThr = 50;% min gap between energy peaks in us. Anything less
% will be merged into one detection the beginning of the next is fewer
% samples than this, the signals will be merged.



% if you're using wav files that have a time stamp in the name, put a
% regular expression for extracting that here:
parametersHR.DateRE = '_(\d*)_(\d*)';
% mine look like "filename_20110901_234905.wav" 
% ie "*_yyyymmdd_HHMMSS.wav"

%%% Output file extensions. Probably don't need to be changed %%%
parametersHR.clickAnnotExt = 'cTg';
parametersHR.ppExt = 'pTg';
parametersHR.groupAnnotExt = 'gTg';
