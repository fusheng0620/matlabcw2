function temp_monitor(a)
% TEMP_MONITOR Monitors the temperature in real time and indicates the current temperature range via LED status.
% temp_monitor(a) Collects data once per second using the MCP9700A temperature sensor.
% When the temperature is between 18°C and 24°C, the green LED is always on; 
% When the temperature is lower than 18°C, the yellow LED blinks at 0.5 second intervals; 
% When the temperature is higher than 24°C, the red LED blinks at 0.5 second intervals.
% Also displays a graph of the real-time temperature change, and the input parameter a is an Arduino object.

    % MCP9700A Parameters
    V0 = 0.5;         % Output voltage (V) for 0°C
    TC = 0.01;        % Increase by 10mV per °C
    analogPin = 'A0';  % Analog Input Pin
    
    % LED Pin Definition
    redLED = 'D10';
    yellowLED = 'D8';
    greenLED = 'D9';

    % Initialize LED Status
    writeDigitalPin(a, redLED, 0);
    writeDigitalPin(a, yellowLED, 0);
    writeDigitalPin(a, greenLED, 0);
    
    timeData = [];
    tempData = [];

    % For smoothing
    tempBuffer = [];      % Buffer for recent temperature readings
    windowSize = 5;       % Size of the median filter window

    tStart = datetime('now');
    lastUpdate = 0;           % time of last blink 
    flashState = 0;          % blink state toggle (0 or 1)

    while true
        tNow = datetime('now');
        elapsed = seconds(tNow - tStart);
        voltage = readVoltage(a, analogPin);
        temp = (voltage - V0) / TC;

        % Add new temp to buffer
        tempBuffer(end+1) = temp;
        if length(tempBuffer) > windowSize
            tempBuffer(1) = [];       % Remove oldest if exceeding window size
        end

        % Use median temperature for plotting and LED control
        smoothTemp = median(tempBuffer);

        timeData(end+1) = elapsed;
        tempData(end+1) = smoothTemp;

         % Real-time image updates
        plot(timeData, tempData, '-r');
        xlim([max(0, elapsed - 60), elapsed + 5]);
        ylim([min(tempData)-1, max(tempData)+1]);
        xlabel('time（s）');
        ylabel('temperature（°C）');
        title('Real-time temperature monitoring');
        drawnow;

        % LED control logic (non-blocking)
        dt = elapsed - lastUpdate;

        if temp < 18
            % yellow light blink
            writeDigitalPin(a, greenLED, 0);
            writeDigitalPin(a, redLED, 0);
            if dt >= 0.5
                flashState = ~flashState;
                writeDigitalPin(a, yellowLED, flashState);
                lastUpdate = elapsed;
            end
        elseif temp > 24
            % red light blink
            writeDigitalPin(a, greenLED, 0);
            writeDigitalPin(a, yellowLED, 0);
            if dt >= 0.25
                flashState = ~flashState;
                writeDigitalPin(a, redLED, flashState);
                lastUpdate = elapsed;
            end
        else
            % Constant green light
            writeDigitalPin(a, redLED, 0);
            writeDigitalPin(a, yellowLED, 0);
            writeDigitalPin(a, greenLED, 1);
            lastUpdate = elapsed;
        end

        pause(0.1); % Fast polling for more responsive image and LED control
    end
end
