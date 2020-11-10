clearvars -except t1 t2
close all
clc

%% Geolocation with Kinect

% Listen on socket
% differentiate between connected users
% read data
% do math
figure;
second = true;
if exist('t1', 'var')
    closeSocket(t1);
    clear t1
    if second && exist('t2', 'var')
        closeSocket(t2);
        clear t2
    end
    pause(1)
end

t1 = tcpip('0.0.0.0', 8032, 'NetworkRole', 'server');
if second
    t2 = tcpip('0.0.0.0', 8033, 'NetworkRole', 'server');
end
% global angles;
% global index;
% angles = repmat(struct(), 20, 2);
% index = 1;
% kinectIndex = 1;
% t.BytesAvailableFcnMode = 'byte';
% t.BytesAvailableFcnCount = 512;
% t.BytesAvailableFcn = {@readAngleData, kinectIndex};
fopen(t1);
if second
    fopen(t2);
end
scale = 10;
loc1 = [0, 0, deg2rad(0)];
loc2 = [6.5, 3.5, deg2rad(270)];
% Read the buffer, this is the order
% index | angle | confidence | duration | relative time | numsamples | audio sample | ...
% int32 | float | float      | int64    | int64         | int32      | float
% 

% while 1
% end
numToRead = 1000;
data = repmat(struct(), numToRead, 1);
maxAngle = deg2rad(50);
maxDrawAngle = deg2rad(90);
minRes = deg2rad(5);




count = 1;
% for ii = 1:numToRea
while 1
    ii = 1;

    beam1 = readAudioBeamData(t1);
    if ~isfield(beam1, 'index')
        continue;
    end
    if second
        beam2 = readAudioBeamData(t2);
        if ~isfield(beam1, 'index')
            continue;
        end
    end

    if mod(count, 10) == 0
        angle = -1*beam1.angle;
        angleConf = (minRes-maxAngle)*beam1.confidence + maxAngle;
%         minTheta = max([angle-angleConf -maxDrawAngle])+loc1(3);
%         maxTheta = min([angle+angleConf maxDrawAngle])+loc1(3);
        minTheta = angle-angleConf + loc1(3);
        maxTheta = angle+angleConf + loc1(3);
        theta = linspace(minTheta, maxTheta, 50);
        x = sin(theta)*scale+loc1(1);
        y = cos(theta)*scale+loc1(2);
        fill([loc1(1) x], [loc1(2) y], 'c', 'FaceAlpha', 0.5);
        line([loc1(1) sin(angle+loc1(3))*scale+loc1(1)], [loc1(2) cos(angle+loc1(3))*scale+loc1(2)]);
        axis([-8 11 -2 11]);
        if second
            hold on


            angle = -1*beam2.angle;
            angleConf = (minRes-maxAngle)*beam2.confidence + maxAngle;
%             minTheta = max([angle-angleConf -maxDrawAngle]);
%             maxTheta = min([angle+angleConf maxDrawAngle]);
            minTheta = angle-angleConf + loc2(3);
            maxTheta = angle+angleConf + loc2(3);
            theta = linspace(minTheta, maxTheta, 50);
            x = sin(theta)*scale+loc2(1);
            y = cos(theta)*scale+loc2(2);
            fill([loc2(1) x], [loc2(2) y], 'm', 'FaceAlpha', 0.5);
            line([loc2(1) sin(angle+loc2(3))*scale+loc2(1)], [loc2(2) cos(angle+loc2(3))*scale+loc2(2)], 'Color', 'm');
    %         axis([-1 1 0 1]);
            hold off
        end
        drawnow;
    end
    count = count + 1;
    
end

closeSocket(t1);
if second
    closeSocket(t2);
end

