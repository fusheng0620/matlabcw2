% Yiwen ZOU
% ssyyz44@nottingham.edu.cn

%% PRELIMINARY TASK - AEDUINO AND GIT INSTALLATTION
clear 
clc

% Connect the arduino 
a = arduino(); % MATLAB will automatically recognize the first connected device 

% Set the digital pin number (e.g. D6) 
ledPin = 'D6';
interval = 0.5;

% LED blinks 10 times 
for i = 1:10
    writeDigitalPin(a, ledPin, 1);  % Light the LED 
    pause(interval);                     % wait 0.5 sec 
    writeDigitalPin(a, ledPin, 0);  % extinguish LED 
    pause(interval);                    % wait 0.5 sec 
end
%%
%% TASK1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE
% a) Determine connection port 
clc
clear
a = arduino();
analogPin = 'A0';

% Temperature conversion parameter (adjusted according to the sensor's documentation) 
V0 = 0.5;           % Output voltage at 0°C 
TC = 0.01;          % Increase by 10mV per °C from 

%% b) Initialize Variables 
duration = 600;         % Duration: 600 seconds = 10 minutes 
interval = 1;           % Acquisition every second 
numPoints = duration / interval;
voltages = zeros(1, numPoints);
temperatures = zeros(1, numPoints);
timeStamps = zeros(1, numPoints);

disp('Starting to collect temperature data...');

for i = 1:numPoints
    v = readVoltage(a, analogPin);           % read Voltage 
    voltages(i) = v;
    temperatures(i) = (v - V0) / TC;         % Voltage to Temperature 
    timeStamps(i) = (i - 1) * interval;
    pause(interval);
end

disp('Data collection complete.') ;

% statistics
minTemp = min(temperatures);
maxTemp = max(temperatures);
meanTemp = mean(temperatures);

fprintf('Minimum Temperature: %.2f °C\nMaximum Temperature: %.2f °C\nMean Temperature: %.2f °C\n', minTemp, maxTemp, meanTemp); 

%% c) Plotting
figure;
plot(timeStamps, temperatures, '-');
xlabel('Time in seconds');
ylabel('Temperature in °C');
title('Plot of temperature changes in the cabin')
grid on;

%% d) Print formatted information to screen
% Use sprintf to construct output string
startDateStr = sprintf('Data logging startup - %s\n', datestr(now, 'dd/mm/yyyy'));
locationStr = 'Location - Nottingham\n\n';
fprintf('%s' , startDateStr); % Print startup information
fprintf('%s', locationStr); % Print location
% Loop through each minute of data
for i = 1:numPoints
    t = timeStamps(i);
    if mod(t, 60) == 0 % whole minutes
        minute = t / 60;
        temp = temperatures(i);
        % Construct output information for each minute
        minuteStr = sprintf('minute \t\t%d\n', minute);
        tempStr = sprintf('temperature \t%.2f C\n\n', temp);
        fprintf('%s', minuteStr);
        fprintf('%s', tempStr);
    end
end
%% e) Write file
filename = 'cabin_temperature.txt';
fid = fopen(filename, 'w');

% Write header information
fprintf(fid, '--- Cabin Temperature Logs ---\n');
fprintf(fid, 'Record time: %s\n', datestr(now, 'dd/mm/yyyy'));
fprintf(fid, 'Location - Nottingham \n\n');

% write data
for i = 1:numPoints
    t = timeStamps(i);
    if mod(t, 60) == 0              % write every full minute
        temp = temperatures(i);
        minute = t / 60;
        % Construct a line of records for each minute
        line = sprintf('Minute %d \t Time: %3d s\nTemperature:    %.2f°C\n', minute, t, temp);
        fprintf(fid, '%s', line);   % write to file
    end
end

% Write statistics
fprintf(fid, '\n statistics: \n');
fprintf(fid, 'Minimum temperature: %.2f °C\n', minTemp);
fprintf(fid, 'Maximum temperature: %.2f °C\n', maxTemp);
fprintf(fid, 'Mean temp: %.2f °C\n', meanTemp);

fclose(fid);
disp(['Data has been written to file:', filename]);
%%
%% TASK2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION
clc
clear
a = arduino();
temp_monitor(a);  % Calling the temperature detection function
%%
%% TASK3 - ALGORITHMS - TEMPERATURE PREDICTION
clc
clear
a = arduino();
temp_prediction(a);
%%
%% TASK4 - REFLECTIVE STATEMENT
% This project used an Arduino board and an MPCP9700A thermistor to monitor ambient temperature,
% involving three main tasks: recording and analyzing temperature data, controlling LEDs based on a specified temperature range, and predicting temperature changes.
% Some issues were encountered during the design process. %The structure of this design is modular and relatively clear, making it easy to modify and debug.
% For instance, in Task 2, synchronizing LED responses with real-time plotting required precise timing. 
% The structure of this design is modular and relatively clear, making it easy to modify and debug.
% However, the project still has limitations.
% The accuracy of the thermistor is affected by power supply stability and self-heating effects, which reduce the overall precision of the design.
% In future iterations, using a more accurate temperature sensor instead of a thermistor could improve the stability of temperature readings.