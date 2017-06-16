function parametersHR = dLoad_HRsettings

%%% Filter and FFT params %%
parametersHR.bpRanges = [28000,99900]; % Bandpass filter params in Hz [min,max]
parametersHR.frameLengthUs = 1200; % For fft computation
parametersHR.overlap = .5; % FFT overlap (in decimal, not percent form)
parametersHR.chan = 1; % which channel do you want to look at?
parametersHR.clipThreshold = .80;%  Normalized clipping threshold btwn 0 and 1.  If empty, 
% assumes no clipping. %Changed from 0.98 150731


%%% Recieved level threshold params %%%
%parametersHR.ppThresh = 100;% minimum  RL threshold - dB peak to peak.
parametersHR.ppThresh = 50;% lowered with new filter 150629, 170420 lowered for kona23 from 80 to 50
%parametersHR.ppThresh = 30; %Adjusted for having no tf.
% parametersHR.countThresh = 1000; % Keep consistent with Lo-res for predictability.
% Can be higher than low res, but not lower!
%170420 lowered from 20K to 1K for hawk 23
% Keep count threshold less than equivalent pp threshold. 
%   dBs = 10*log10(abs(fft(counts *2^14))) - 10*log10(fs/(length(fftWindow)))...
%            + transfer function
% note: array uses 2^15
parametersHR.countThresh = 1200;%Up to 5K for HAWK 23 200 kHz not guided

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
parametersHR.cutPeakBelowKHz = 90; % discard click if peak frequency below X kHz
parametersHR.cutPeakAboveKHz = 99.9; % discard click if peak frequency above Y kHz 
parametersHR.minClick_us = 100;% Minimum duration of a click in us ,170418 up to 100 from 25
parametersHR.maxClick_us = 1000; % Max duration of a click including echos
% parametersHR.maxNeighbor = 1; % max time in seconds allowed between neighboring 
% clicks. Clicks that are far from neighbors can be rejected using this parameter,
% good for dolphins in noisy environments because lone clicks or pairs of
% clicks are likely false positives
parametersHR.maxClick95_us = 500; % Max duration of 95% of the click,
%including echos. Measures a shorter segment of the click than maxClick_us, 
%so, if they are set to the same number that one will not be used (clicks will
%get thrown out with this first). 170327 set to 270 for VJanik data, to
%remove double-clicks (echoes?) Set to 260 for DMann data to remove single
%outlier at 350 us. Otherwise, set to 500
%to remove spurious signals.


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
