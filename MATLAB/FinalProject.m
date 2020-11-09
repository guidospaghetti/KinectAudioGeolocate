clear all
close all
clc

%% Geolocation with Kinect

% Listen on socket
% differentiate between connected users
% read data
% do math
figure;
t = tcpip('0.0.0.0', 8032, 'NetworkRole', 'server');
global angles;
global index;
angles = repmat(struct(), 20, 2);
index = 1;
kinectIndex = 1;
t.BytesAvailableFcnMode = 'byte';
t.BytesAvailableFcnCount = 512;
t.BytesAvailableFcn = {@readAngleData, kinectIndex};
fopen(t);

% Read the buffer, this is the order
% index | angle | confidence | duration | relative time | numsamples | audio sample | ...
% int32 | float | float      | int64    | int64         | int32      | float
% 

while 1
end
numToRead = 1000;
data = repmat(struct(), numToRead, 1);
maxAngle = deg2rad(50);
maxDrawAngle = deg2rad(90);
minRes = deg2rad(5);




% tic;
% count = 1;
% for ii = 1:numToRea
% while 1
%     ii = 1;
% 
%     indexArray = uint8(fread(t, 4, 'uint8'));
%     data(ii).index = typecast(indexArray, 'int32');
%     
%     angleArray = uint8(fread(t, 4, 'uint8'));
%     data(ii).angle = typecast(angleArray, 'single');
%     
%     confidenceArray = uint8(fread(t, 4, 'uint8'));
%     data(ii).confidence = typecast(confidenceArray, 'single');
%     
%     durationArray = uint8(fread(t, 8, 'uint8'));
%     data(ii).duration = typecast(durationArray, 'int64');
%     
%     relTimeArray = uint8(fread(t, 8, 'uint8'));
%     data(ii).relTime = typecast(relTimeArray, 'int64');
%     
%     numSamplesArray = uint8(fread(t, 4, 'uint8'));
%     data(ii).numSamples = typecast(numSamplesArray, 'int32');
%     
%     if data(ii).numSamples <= 0 || data(ii).numSamples > 300
%         disp(['Got ' num2str(data(ii).numSamples) ' numSamples, BAD!']);
%         continue;
%     end
%     
%     data(ii).samples = zeros(data(ii).numSamples, 1);
%     bufferSize = t.InputBufferSize;
%     bytesToRead = double(data(ii).numSamples*4);
%     byteIdx = 0;
%     startIdx = 1;
%     for jj = 1:ceil(bytesToRead/bufferSize)
% 
%         numBytes = min(bufferSize, bytesToRead-byteIdx);
%         sampleArray = uint8(fread(t, numBytes, 'uint8'));
%         stopIdx = startIdx+length(sampleArray)/4-1;
%         data(ii).samples(startIdx:stopIdx) = typecast(sampleArray, 'single');
%         startIdx = stopIdx+1;
%         bytesIdx = byteIdx+numBytes;
%     end
%     
%     
%     if mod(count, 10) == 0
%         angle = data(ii).angle;
%         angleConf = (minRes-maxAngle)*data(ii).confidence + maxAngle;
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
%     count = count + 1;
% end
% toc;

closeSocket(t);

