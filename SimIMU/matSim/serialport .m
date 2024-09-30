% Define the serial port (adjust according to your setup)
serialPort = 'COM5';  % Change COM3 to the port your Arduino is connected to
baudRate = 115200;

% Set up the serial object
s = serial(serialPort, 'BaudRate', baudRate, 'Terminator', 'LF');
fopen(s);

% Create a 3D plot for visualization
figure;
[x, y, z] = sphere;
h = surf(0.5*x, 0.5*y, 0.5*z);  % Sphere representing the IMU
axis([-1 1 -1 1 -1 1]);
xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
view([45,30]);

% Real-time update loop
while true
    % Read the serial data
    if s.BytesAvailable > 0
        data = fgetl(s);  % Read one line from the serial port
        imuData = str2num(data);  % Convert CSV string to a numeric array
        
        if length(imuData) == 3
            roll = imuData(1);
            pitch = imuData(2);
            yaw = imuData(3);
            
            % Calculate the rotation matrix based on roll, pitch, yaw
            Rx = [1 0 0; 0 cosd(roll) -sind(roll); 0 sind(roll) cosd(roll)];
            Ry = [cosd(pitch) 0 sind(pitch); 0 1 0; -sind(pitch) 0 cosd(pitch)];
            Rz = [cosd(yaw) -sind(yaw) 0; sind(yaw) cosd(yaw) 0; 0 0 1];
            R = Rz * Ry * Rx;
            
            % Rotate the 3D object
            h.XData = R(1,1)*x + R(1,2)*y + R(1,3)*z;
            h.YData = R(2,1)*x + R(2,2)*y + R(2,3)*z;
            h.ZData = R(3,1)*x + R(3,2)*y + R(3,3)*z;
            
            % Update the plot
            drawnow;
        end
    end
end

% Close the serial connection
fclose(s);
delete(s);
clear s;
