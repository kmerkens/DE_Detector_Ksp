function parametersST = dLoad_STsettings

% Assign short term detector settings

parametersST.buff = 500; % # of buffer samples to add on either side of area of interest
parametersST.chan = 1; % which channel do you want to look at?

parametersST.fRanges = [90000 99000]; %Narrowed to 90-99.9K
%parametersST.thresholds = 3500; % Amplitude threshold in counts.
% parametersST.thresholds = 1000; %Increased for new filtering, 170420 
%lowered from 20K to 1K for hawk 23 guided
parametersST.thresholds = 1200;
% For predictability, keep this consistent between low and hi res steps.

parametersST.frameLengthSec = .01; %Used for calculating fft size
parametersST.overlap = .50; % fft overlap
parametersST.REWavExt = '(\.x)?\.wav';%  expression to match .wav or .x.wav

% if you're using wav files that have a time stamp in the name, put a
% regular expression for extracting that here:
parametersST.DateRE = '_(\d*)_(\d*)';
% mine look like "filename_20110901_234905.wav" 
% ie "*_yyyymmdd_HHMMSS.wav"


