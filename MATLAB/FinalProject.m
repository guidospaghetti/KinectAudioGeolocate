clear all
close all
clc

%% Geolocation with Kinect

% Listen on socket
% differentiate between connected users
% read data
% do math

t = tcpip('0.0.0.0', 8032, 'NetworkRole', 'server');
fopen(t);

% Read the buffer, this is the order
% index | angle | confidence | duration | relative time | numsamples | audio sample | ...
% int32 | float | float      | int64    | int64         | int32      | float
% 

numToRead = 1000;
data = repmat(struct(), numToRead, 1);
tic;
for ii = 1:numToRead

    indexArray = uint8(fread(t, 4, 'uint8'));
    data(ii).index = typecast(indexArray, 'int32');
    
    angleArray = uint8(fread(t, 4, 'uint8'));
    data(ii).angle = typecast(angleArray, 'single');
    
    confidenceArray = uint8(fread(t, 4, 'uint8'));
    data(ii).confidence = typecast(confidenceArray, 'single');
    
    durationArray = uint8(fread(t, 8, 'uint8'));
    data(ii).duration = typecast(durationArray, 'int64');
    
    relTimeArray = uint8(fread(t, 8, 'uint8'));
    data(ii).relTime = typecast(relTimeArray, 'int64');
    
    numSamplesArray = uint8(fread(t, 4, 'uint8'));
    data(ii).numSamples = typecast(numSamplesArray, 'int32');
    
    if data(ii).numSamples <= 0 || data(ii).numSamples > 300
        disp(['Got ' num2str(data(ii).numSamples) ' numSamples, BAD!']);
        continue;
    end
    
    data(ii).samples = zeros(data(ii).numSamples, 1);
    bufferSize = t.InputBufferSize;
    bytesToRead = double(data(ii).numSamples*4);
    byteIdx = 0;
    startIdx = 1;
    for jj = 1:ceil(bytesToRead/bufferSize)

        numBytes = min(bufferSize, bytesToRead-byteIdx);
        sampleArray = uint8(fread(t, numBytes, 'uint8'));
        stopIdx = startIdx+length(sampleArray)/4-1;
        data(ii).samples(startIdx:stopIdx) = typecast(sampleArray, 'single');
        startIdx = stopIdx+1;
        bytesIdx = byteIdx+numBytes;
    end
    dur = seconds(double(data(ii).relTime)/1e7);
    epoch = datetime('now')-dur
end
toc;

fclose(t);
delete(t);
clear t;

