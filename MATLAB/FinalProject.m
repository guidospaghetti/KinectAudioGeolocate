clearvars -except tcp
close all
clc

%% Geolocation with Kinect

% Listen on socket
% differentiate between connected users
% read data
% do math


numSensors = 2;
startingPort = 8032;

scale = 10;
locations = [0, 0, deg2rad(0);
             6.5, 3.5, deg2rad(270)];
plotAxis = [-8 11 -2 11];
% Kinect measures across +-50 degrees
% Resolution of measurements is 5 degrees
maxAngle = deg2rad(50);
minRes = deg2rad(5);
colors = ['c', 'm', 'g', 'r', 'y'];

if exist('tcp', 'var')
    for ii = 1:numSensors
        closeSocket(tcp{ii})
    end
    clear tcp
    pause(1);
end

count = 1;
beam(1:numSensors) = struct('index', [], 'angle', [], 'confidence', [], 'duration', [], ...
    'relTime', [], 'numSamples', [], 'samples', []);

figure;
tcp = cell(numSensors, 1);
for ii = 1:numSensors
    tcp{ii} = tcpip('0.0.0.0', startingPort+ii-1, 'NetworkRole', 'server');
end

for ii = 1:numSensors
    fopen(tcp{ii});
end

for ii = 1:numSensors
    flushinput(tcp{ii});
end

while 1
    
    skip = false;
    for ii = 1:numSensors
        beam(ii) = readAudioBeamData(tcp{ii});
        if ~isfield(beam(ii), 'index')
            skip = true;
        end
    end
    if skip
        continue;
    end

    if mod(count, 10) == 0
        for ii = 1:numSensors
            angle = -1*beam(ii).angle;
            angleConf = (minRes-maxAngle)*beam(ii).confidence + maxAngle;
            minTheta = angle-angleConf + locations(ii, 3);
            maxTheta = angle+angleConf + locations(ii, 3);
            theta = linspace(minTheta, maxTheta, 50);
            x = sin(theta)*scale+locations(ii, 1);
            y = cos(theta)*scale+locations(ii, 2);
            
            if ii > 1
                hold on
            end
            fill([locations(ii, 1) x], [locations(ii, 2) y], colors(ii), 'FaceAlpha', 0.5);
            line([locations(ii, 1) sin(angle+locations(ii, 3))*scale+locations(ii, 1)], ...
                 [locations(ii, 2) cos(angle+locations(ii, 3))*scale+locations(ii, 2)]);
            axis(plotAxis);
            if ii > 1
                hold off
            end
        end
        drawnow;
    end
    count = count + 1;
    
end

