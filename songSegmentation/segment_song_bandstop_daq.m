function segment_song_bandstop_daq(exptPath, savepath)
%SEGMENT_SONG_BANDSTOP Segment song for an experiment.
% Usage:
%   segment_song_bandstop(exptPath, savepath)

addpath(genpath('MurthyLab_FlySongSegmenter'));
fprintf('Added song segmenter tools to path\n\n');

fprintf('Experiment path is %s\n', exptPath);

%% Find paths and load data
if ~endsWith(exptPath,'daq.h5')
    disp('Please supply a daq.h5 file as input');
end

if ~endsWith(savepath, '.mat')
    disp('Please supply a .mat file as a savepath');
end
% savePath = ff(fileparts(exptPath),'daq_segmentation_new.mat');

stic;

%% Read data from daq.h5
recording = h5read(exptPath, '/audio');

Fs = 1e4;

[samples, channels] = size(recording);

% Exclude the final channel which contains camera exposure active info
if channels > 9
    recording = recording(:, 1:9);
    [samples, channels] = size(recording);
end


stocf('Loaded: %s (%d x %d)', exptPath, samples, channels)

%% Baseline subtract and bandstop filter
stic;
bandstop_window = [-3 3]+120;

baselineVoltage = 3.75/2;
recording = recording - baselineVoltage;
recording = bandstop(recording,bandstop_window,Fs);

stocf('Baseline subtracted and bandstop filtered: %s', mat2str(bandstop_window))

%% Segment song in each channel
t0_all = stic;
sInf = struct();
parfor chn = 1:channels
   fprintf('Segmenting channel %d.\n', chn)
   t0 = stic;
   [sInf(chn).nLevel, sInf(chn).winSine, sInf(chn).pulseInfo, sInf(chn).pulseInfo2, sInf(chn).pcndInfo, sInf(chn).noise] = ...
      segmentSong(recording(:,chn), 'params.m');
  stocf(t0, '*===== Finished channel %d/%d =====*', chn, channels)
end
stocf(t0_all,'*Finished segmenting all channels*')

save(savepath, 'exptPath','Fs', 'bandstop_window', 'sInf', 'recording');
stocf('Saved initial segmentation results. Post-processing now')

%% Post process
bufferLen =  2e3; % samples
t0 = stic;
noiseSample = findNoise(recording, bufferLen);
oneSong = mergeChannels(recording)';
[sInf, pInf, wInf, bInf, song] = postProcessSegmentation(sInf, recording, oneSong, noiseSample);
song = song(:);
pulseTimesAutomatic = pInf.wc/Fs;
stocf(t0,'Finished post processing song')

%% Classify pulses
t0 = stic;
pulsesNorm = normalizePulses(pInf.pSec);           % normalize pulses
pulseLabels = classifyPulses(pulsesNorm);       % classify pulses - 0=Pfast, 1=Pslow
stocf(t0,'Finished classifying pulses')
fprintf('%d/%d Pfast, %d/%d Pslow.\n', sum(pulseLabels==0), length(pulseLabels), sum(pulseLabels==1), length(pulseLabels))

%% Convenience structures
pulse = bInf.Mask == 1;
sine = bInf.Mask == 2;
pfast = false(size(pulse));
pslow = false(size(pulse));

window = -125:125;
for i = 1:numel(pulseLabels)
    idx = window + pInf.wc(i);
    if pulseLabels(i) == 0 % pslow
        pslow(idx) = true;
    elseif pulseLabels(i) == 1 % pfast
        pfast(idx) = true;
    end
end

ts = (0:numel(song)-1) / Fs;

%% Save
save(savepath, 'exptPath','Fs', 'bandstop_window', ...
    'oneSong','noiseSample', 'sInf','pInf', 'wInf', 'bInf', 'song', ...
    'pulseTimesAutomatic', 'pulsesNorm', 'pulseLabels', ...
    'pulse','sine','pfast','pslow','ts', '-append')
printf('Saved post-processing: %s', savepath)
end
