% oxygen3D_Viz.m
% 3D Visualization of Oxygen Data (Animated).
%
% Input:
%   - Select oxygen netCDF file ('Oxygen.nc' by default).
%
% Output:
%   - Animated AVI video file ('Oxygen_2015-17.avi').
%   - MATLAB figure showing animation.
%   - MATLAB variable 'im' containing image frames saved to 'oxygen_image.mat'.
%
% Author: PAVAN KUMAR JONNAKUTI
% Project Scientist - B
% Data Information & Management Group
% Indian National Centre for Ocean Information Services (INCOIS)
% "Ocean Valley", Pragathi Nagar (B.O)
% Nizampet (S.O), Hyderabad - 500 090
% Telangana, INDIA
% E-mail: jpawan33@gmail.com
% Web-link: http://jpavan.com
% Copyright @ Author
%
% Description:
% This script reads oxygen data from a netCDF file, generates a 3D
% visualization of the data over time, and creates an animated AVI video.

clc; clear all; close all;

%% Input File and Data Loading
handles.filename = 'Oxygen.nc';
handles.lon = ncread(handles.filename, 'lon');
handles.lat = ncread(handles.filename, 'lat');
handles.time = ncread(handles.filename, 'time');
handles.depth = ncread(handles.filename, 'dep');

% Convert time to datetime objects
T1 = datetime('01-January-2015 12:00');
T2 = T1 + days(length(handles.time) - 1);
handles.T = T1:T2;

%% Create Meshgrid
[LON, LAT, Z] = meshgrid(handles.lon, handles.lat, handles.depth);
n = length(handles.T); % Number of time steps
nImages = n;

% Load coastline data
load coastlines.mat

%% Create Figure and Animation Frames
fig = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
ax1 = gca;
im = cell(nImages, 1);

for iloop = 1:n
    % Read oxygen data for the current time step
    Oxy = ncread(handles.filename, 'O21', [1, 1, 1, iloop], [inf inf inf 1]);

    % Visualize using pcolor3
    pcolor3(LON, LAT, -Z, permute(single(Oxy), [2 1 3]));

    % Set plot properties
    title(sprintf('Time: %s', handles.T(iloop)));
    xlabel('Longitude');
    ylabel('Latitude');
    zlabel('Depth(m)');
    colormap('jet(256)');

    % Add colorbar
    h = colorbar(gca, 'Location', 'EastOutside');
    minData = 0; maxData = 250;
    caxis([minData maxData]);
    set(h, 'YTick', minData:10:maxData);
    ylabel(h, 'Oxygen');

    drawnow();
    axis tight;
    grid off;
    set(gca, 'Color', [0.83 0.82 0.78]);
    box on;
    ax1.BoxStyle = 'full';
    view(-41, 18);

    % Add coastline
    hold on;
    plot(coastlon, coastlat, 'k', 'Linewidth', 3);
    ylim([0 30]);
    xlim([45 100]);
    hold off;

    % Capture frame and save to cell array
    frame = getframe(fig);
    im{iloop} = frame2im(frame);

    disp(num2str(iloop)); % Display progress
end

% Save image frames to MAT file
save oxygen_image.mat -v7.3 im;

%% Create Animation File (AVI)
filename = 'Oxygen_2015-17.avi';
writerObj = VideoWriter(filename);
writerObj.FrameRate = 10;
open(writerObj);

for idx = 1:nImages
    writeVideo(writerObj, im{idx});
end

close(writerObj);
