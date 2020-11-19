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

scale = 3;
% X pos, Y pos, draw angle offset, algorithm angle offset
% Sensor 1; Sensor 2; truth
locations = [0, 0, deg2rad(0), deg2rad(0);
             1.9812, 1.1303, deg2rad(270), deg2rad(90);
             0, 1.6637, 0, 0];
overallAngleOffset = deg2rad(90);
plotAxis = [-2.4 2.25 -0.6 2.25];
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
measurementCount = 1;
% Taken roughly every 16 ms, keep max 2 seconds around, 2/0.016 = 125
maxMeasurements = 125;
displayEvery = 20;
x_hat = [];
P = [];
beam(maxMeasurements, 1:numSensors) = struct('index', [], 'angle', [], 'confidence', [], 'duration', [], ...
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
        beam(measurementCount, ii) = readAudioBeamData(tcp{ii});
        if ~isfield(beam(measurementCount, ii), 'index')
            skip = true;
        end
    end
    if skip
        continue;
    end
    
    if mod(count, displayEvery) == 0
        for ii = 1:numSensors
            angle = -1*beam(measurementCount, ii).angle;
            angleConf = (minRes-maxAngle)*beam(measurementCount, ii).confidence + maxAngle;
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
        if ~isempty(x_hat)
            hold on
            scatter(x_hat(1), x_hat(2));
            hold off;
        end
        if ~isempty(P)
            ellipse = constructEllipse(P, x_hat, 0.95);
            hold on
            scatter(ellipse(1, :), ellipse(2, :), 3);
            hold off
        end
        drawnow;
    end
    
    if (measurementCount ~= 0) && (mod(count, displayEvery) == 0)
        % Do math
        % Start with DOA
        % Do ILS using the stored measurements
        % Convert relative angle into true angle
        % Convert angle confidence into measurement uncertainty
        % Calculate h and H, converge
        
        x_init = [1; 1];
        x_old = x_init;
%         angles = reshape(vertcat(beam.angle), [], numSensors);
%         angleConf = reshape(vertcat(beam.confidence), [], numSensors);
        angles = vertcat(beam.angle);
        angleConf = vertcat(beam.confidence);
        angles = angles+overallAngleOffset;
        angleConf = ((minRes-maxAngle)*angleConf + maxAngle);
        R = diag(angleConf);
        sensor = zeros(length(angles), 1);
        sensor(1:length(angles)/2) = 1;
        sensor(length(angles)/2+1:end) = 2;
        angles = angles+locations(sensor, 4);
        range = zeros(numSensors, 1);
        z = angles;
        epsilon = 0.001;
        err = epsilon + 1;
        maxIterations = 100;
        bad = false;
        for ii = 1:maxIterations
%             h = atan((x_old(2)-locations(sensor, 2))./(x_old(1)-locations(sensor, 1)))+locations(sensor,4);
            x = (x_old(1)-locations(sensor, 1));
            y = (x_old(2)-locations(sensor, 2));
            h = atan(y./x);
            h(x < 0 & y >= 0) = h(x < 0 & y >= 0)+pi;
            h(x < 0 & y < 0) = h(x < 0 & y < 0)+pi;
            h(x == 0 & y > 0) = pi/2;
            h(x == 0 & y < 0) = -pi/2;
            range(1) = sqrt((x_old(1)-locations(1, 1))^2+(x_old(2)-locations(1, 2))^2);
            range(2) = sqrt((x_old(1)-locations(2, 1))^2+(x_old(2)-locations(2, 2))^2);
            H = (1./(range(sensor).^2)).*[-1*(x_old(2)-locations(sensor,2)) x_old(1)-locations(sensor,1)];

            x_new = x_old + inv(H'*inv(R)*H)*H'*inv(R)*(z - h);
            if any(abs(x_new) > 1000) || any(isnan(x_new))
                bad = true;
                break;
            end
            err = norm(x_new - x_old);
            if err < epsilon
                bad = false;
                break;
            end
            x_old = x_new;
        end
        if bad
            x_hat = [];
            P = [];
        else
            x_hat = x_new;
            P = inv(H'*inv(R)*H);
%             disp(x_hat);
        end
        
    end
    
    measurementCount = measurementCount + 1;
    if measurementCount > maxMeasurements
        measurementCount = 1;
    end
    count = count + 1;
    
end

