function data = readAudioBeamData(t)

data = struct;

indexArray = uint8(fread(t, 4, 'uint8'));
data.index = typecast(indexArray, 'int32');

angleArray = uint8(fread(t, 4, 'uint8'));
data.angle = typecast(angleArray, 'single');

confidenceArray = uint8(fread(t, 4, 'uint8'));
data.confidence = typecast(confidenceArray, 'single');

durationArray = uint8(fread(t, 8, 'uint8'));
data.duration = typecast(durationArray, 'int64');

relTimeArray = uint8(fread(t, 8, 'uint8'));
data.relTime = typecast(relTimeArray, 'int64');

numSamplesArray = uint8(fread(t, 4, 'uint8'));
data.numSamples = typecast(numSamplesArray, 'int32');

if data.numSamples <= 0 || data.numSamples > 300
    disp(['Got ' num2str(data.numSamples) ' numSamples, BAD!']);
    data = struct;
    return;
end

data.samples = zeros(data.numSamples, 1);
bufferSize = t.InputBufferSize;
bytesToRead = double(data.numSamples*4);
byteIdx = 0;
startIdx = 1;
for jj = 1:ceil(bytesToRead/bufferSize)

    numBytes = min(bufferSize, bytesToRead-byteIdx);
    sampleArray = uint8(fread(t, numBytes, 'uint8'));
    stopIdx = startIdx+length(sampleArray)/4-1;
    data.samples(startIdx:stopIdx) = typecast(sampleArray, 'single');
    startIdx = stopIdx+1;
    bytesIdx = byteIdx+numBytes;
end