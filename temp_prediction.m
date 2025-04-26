function temp_prediction(a)
% TEMP_PREDICTION monitors the temperature and its rate of change in real time, predicts the future temperature and displays the current trend via LEDs.
% Input parameters: 
% a - initialized Arduino object 
% This function implements: 
% - reads the temperature value every second; 
% - calculates the temperature rate of change (°C/s); 
% - predicts the temperature after 5 minutes; 
% - prints the current temperature and the predicted value; 
% - controls the LED color according to the rate of change of the temperature (red: fast rising, yellow: fast falling, green: stable); 
% can use the MCP9700A sensor, using A0 to receive analog inputs.

    % Initialization parameters
    analogPin = 'A0';
    redLED = 'D10';
    yellowLED = 'D8';
    greenLED = 'D9';

    TC = 0.01;      % 10 mV/°C
    V0 = 0.5;       % Output voltage at 0°C
    Vref = 5.0;     % Arduino AREF
    duration = 300; % Predicted duration (s) for rate-of-change calculations
    windowSize = 5; % Smoothing window size

    tempHist = [];   % Temperature history
    timeHist = [];   % Time history

    disp('start temperature monitor and prediction...');
    tic;
    while true
        t = toc;
        % read analog voltage 
        V = readVoltage(a, analogPin);
        T = (V - V0) / TC;

        % store time and temperature
        tempHist(end+1) = T;
        timeHist(end+1) = t;

        % Smoothing
        if length(tempHist) >= windowSize
            T_smooth = mean(tempHist(end-windowSize+1:end));
        else
            T_smooth = T;
        end

        % calculate the temperature rate of change
        rate = 0;
        if length(tempHist) > 1
            T_prev = mean(tempHist(max(1,end-windowSize):end-1));
            dt = timeHist(end) - timeHist(end-1);
            rate = (T_smooth - T_prev) / dt;
        end

        % Predict future temperature
        T_future = T + rate * duration;

        fprintf('Current temperature: %.2f°C | Rate of change: %.3f°C/s | Predicted temperature (after 5 minutes): %.2f°C\n', T, rate, T_future);

        % Control LED logic (4°C/min = 0.0667°C/s)
        writeDigitalPin(a, redLED, 0);
        writeDigitalPin(a, yellowLED, 0);
        writeDigitalPin(a, greenLED, 0);
        if rate > 0.0667
            writeDigitalPin(a, redLED, 1);
        elseif rate < -0.0667
            writeDigitalPin(a, yellowLED, 1);
        else
            writeDigitalPin(a, greenLED, 1);
        end

        pause(1); % update
    end
end
