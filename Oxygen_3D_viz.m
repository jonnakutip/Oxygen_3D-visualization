% function oxygen3D_Viz()
%% surfaceAge()
% Input: 
% Select oxygen netCDF file
% Output:
% 3D Visualizatoin of OXygen data (Animated file).
% Author:   PAVAN KUMAR JONNAKUTI
%           Project Scientist - B
%           Data Information & Management Group
%           Indian National Centre for Ocean Information Services (INCOIS)
%           "Ocean Valley", Pragathi Nagar (B.O)
%           Nizampet (S.O), Hyderabad - 500 090
%           Telangana, INDIA
% E-mail:   jpawan33@gmail.com
% Web-link: http://jpavan.com
% Copyright @ Author
% code : Visualization of Oxygen Data in Indian Ocean
clc; clear all; close all;
%%
handles.filename    = 'Oxygen.nc';
handles.lon         = ncread(handles.filename,'lon');
handles.lat         = ncread(handles.filename,'lat');
handles.time        = ncread(handles.filename,'time');
handles.depth       = ncread(handles.filename,'dep');
T1                  = datetime('01-January-2015 12:00');
T2                  = T1 + days(length(handles.time)-1);
handles.T           = T1:T2;
%% Meshgrid for local locations
[LON,LAT,Z] = meshgrid(handles.lon,handles.lat,handles.depth);
n = length(handles.T); % Time interval
nImages = n;
load coastlines.mat
fig = figure('units','normalized','outerposition',[0 0 1 1]);
ax1 = gca;
im = cell(nImages,1);
for iloop =1:n
    Oxy = ncread(handles.filename,'O21',[1,1,1,iloop],[inf inf inf 1]);
    pcolor3(LON,LAT,-Z,permute(single(Oxy),[2 1 3]));
    title(sprintf('Time: %s',handles.T(iloop)))
    xlabel('Longitude')
    ylabel('Latitude')
    zlabel('Depth(m)')
    colormap('jet(256)')
    h = colorbar(gca,'Location','East Outside');
    minData = 0; maxData = 250;
    caxis([minData maxData]);
    set(h,'YTick',minData:10:maxData)
    drawnow()
    axis tight
    grid off
    set(gca,'Color',[0.83 0.82 0.78]); %[0.83 0.82 0.78]
    box on
    ax1.BoxStyle ='full';
    view(-41,18)
    ylabel(h, 'Oxygen');
    hold on
    plot(coastlon,coastlat,'k','Linewidth',3)
    ylim([0 30])
    xlim([45 100])
    hold off
    frame = getframe(fig); % Captures every frame of the figure
    im{iloop} = frame2im(frame); % Image data is saved in im
%     delete(h)
    disp(num2str(iloop))
end
save oxygen_image.mat -v7.3 im
%% Create Animation File
filename = 'Oxygen_2015-17.gif'; % Specify the output file name
writerObj = VideoWriter('Oxygen_2015-17.avi'); % Create a video writer object
writerObj.FrameRate = 10; % Set frame rate
open(writerObj) % Open video writer object and write frames sequentially
for idx = 1:nImages
    writeVideo(writerObj, im{idx}); % Write the image data in img to the video file. 
%     [A,map] = rgb2ind(im{idx},256);
%     if idx == 1
%         imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.5);
%     else
%         imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.5);
%     end
end
close(writerObj); % Close the video writer object
