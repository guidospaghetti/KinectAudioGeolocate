function readAngleData(obj, event, kinectIndex)

global angles;
global index;

tic
while obj.BytesAvailable > 0

    maxAngle = deg2rad(50);
    maxDrawAngle = deg2rad(90);
    minRes = deg2rad(5);

    indexArray = uint8(fread(obj, 4, 'uint8'));
    angles(index, kinectIndex).index = typecast(indexArray, 'int32');

    angleArray = uint8(fread(obj, 4, 'uint8'));
    angles(index, kinectIndex).angle = typecast(angleArray, 'single');

    confidenceArray = uint8(fread(obj, 4, 'uint8'));
    angles(index, kinectIndex).confidence = typecast(confidenceArray, 'single');

    durationArray = uint8(fread(obj, 8, 'uint8'));
    angles(index, kinectIndex).duration = typecast(durationArray, 'int64');

    relTimeArray = uint8(fread(obj, 8, 'uint8'));
    angles(index, kinectIndex).relTime = typecast(relTimeArray, 'int64');

    numSamplesArray = uint8(fread(obj, 4, 'uint8'));
    angles(index, kinectIndex).numSamples = typecast(numSamplesArray, 'int32');

    if angles(index, kinectIndex).numSamples <= 0 || angles(index, kinectIndex).numSamples > 300
        disp(['Got ' num2str(angles(index, kinectIndex).numSamples) ' numSamples, BAD!']);
        return;
    end

    angles(index, kinectIndex).samples = zeros(angles(index, kinectIndex).numSamples, 1);
    bufferSize = obj.InputBufferSize;
    bytesToRead = double(angles(index, kinectIndex).numSamples*4);
    byteIdx = 0;
    startIdx = 1;
    for jj = 1:ceil(bytesToRead/bufferSize)

        numBytes = min(bufferSize, bytesToRead-byteIdx);
        sampleArray = uint8(fread(obj, numBytes, 'uint8'));
        stopIdx = startIdx+length(sampleArray)/4-1;
        angles(index, kinectIndex).samples(startIdx:stopIdx) = typecast(sampleArray, 'single');
        startIdx = stopIdx+1;
        byteIdx = byteIdx+numBytes;
    end

%     if mod(index, 10) == 0
%         angle = angles(index, kinectIndex).angle;
%         angleConf = (minRes-maxAngle)*angles(index, kinectIndex).confidence + maxAngle;
%         minTheta = max([angle-angleConf -maxDrawAngle]);
%         maxTheta = min([angle+angleConf maxDrawAngle]);
%         theta = linspace(minTheta, maxTheta, 50);
%         x = sin(theta);
%         y = cos(theta);
%         fill([0 x], [0 y], 'c', 'FaceAlpha', 0.5);
%         line([0 sin(angle)], [0 cos(angle)]);
%         axis([-1 1 0 1]);
%         drawnow;
%     end
    

    if index == size(angles, kinectIndex)
        index = 1;
    else
        index = index + 1;
    end
end

toc

