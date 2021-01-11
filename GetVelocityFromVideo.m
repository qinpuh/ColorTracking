%% 1. load the first image frame and ask the user to locate the painted nail to get its RGB values

%MyPath =  uigetdir('\\bensmaia-lab\LabSharing\TextureForce','Qinpu is waiting for your path?');
MyPath = '\\bensmaia-lab\LabSharing\TextureForce\experiment 2020-12-23\camera_data\experiment_2020_12_23_15_13_47\cam19194013\denimqp_gain20';
cd(MyPath);
FileListAll = dir('*.jpeg');
%to make sure the file names are in ascending orders 
for k = 1 : length(FileListAll)
    FileListAll(k).sortkey = str2double(regexp(FileListAll(k).name, 'image(\d+).jpeg', 'tokens', 'once'))
end
T = struct2table(FileListAll);
sortedT = sortrows(T, 'sortkey');
sortedS = table2struct(sortedT);
FileListAll = sortedS;
numberOfFrames = length(FileListAll);

%% 2. plot the first frame and prompt the user to click the four corners 
%of the first frame and transform it to make it parrallel to the camera
x=[]; y=[]; fontSize = 24;
figure;
hImage=subplot(1,1,1);

fid = 35; %which frame to extract nail color from 
FileListAll = FileListAll(fid:end);
numberOfFrames = length(FileListAll);

thisFrame=imread(FileListAll(1).name);
imshow(thisFrame);
hold on;
maxAllowablePoints = 4; % how many points to collect
numPointsClicked = 0;
promptMessage = sprintf('Click the four corners in sequence from uppermost left counterclockwise', maxAllowablePoints);
titleBarCaption = 'Continue?';
button = questdlg(promptMessage, titleBarCaption, 'Continue', 'Cancel', 'Continue');
if strcmpi(button, 'Cancel')
  return;
end
while numPointsClicked < maxAllowablePoints
  numPointsClicked = numPointsClicked + 1;
  [x(numPointsClicked), y(numPointsClicked), button] = ginput(1)  
  plot(x(numPointsClicked), y(numPointsClicked), 'r+', 'MarkerSize', 15);
  if button == 3
    % Exit loop if
    break;
  end
end
msgbox('Done collecting points');
% Print to command window
moving_points = [x(1),y(1); x(2),y(2); x(3),y(3); x(4),y(4)];
fixed_points = [1, 1500; 1, 1; 1500,1; 1500,1500];
tform = fitgeotrans(moving_points, fixed_points, 'projective');
newimage = imwarp(thisFrame,tform);
%figure;
%imshow(newimage); title('Transformed Image');

%% 3. Click the bottom to corners to get length in pixels; 
% then click on the painted nail to get xy coordinates and rgb values 
% then input the real length 
x=[]; y=[];
fontSize = 24;
figure;
imshow(newimage);
hold on;
maxAllowablePoints = 4; % how many points to collect
numPointsClicked = 0;
promptMessage = sprintf('Click the bottom two corners from LtoR and click on paints and click on center', maxAllowablePoints);
titleBarCaption = 'Continue?';
button = questdlg(promptMessage, titleBarCaption, 'Continue', 'Cancel', 'Continue');
if strcmpi(button, 'Cancel')
  return;
end
while numPointsClicked < maxAllowablePoints
  numPointsClicked = numPointsClicked + 1;
  [x(numPointsClicked), y(numPointsClicked), button] = ginput(1)  
  plot(x(numPointsClicked), y(numPointsClicked), 'r+', 'MarkerSize', 15);
  if button == 3
    % Exit loop if
    break;
  end
end
msgbox('Done collecting points');
len_real = input('What is the real length of one side of the texture board in mm?'); 
%len_real = 25; %just use 25mm for now
len_pixel = x(2)-x(1);
starting_point = [x(3), y(3)];
center_point = [x(4),y(4)];

%painted nail
coordinates_input = [x(3),y(3)];
row = int32(coordinates_input(2));   column = int32(coordinates_input(1));
nailColor = [newimage(row, column, 1), newimage(row, column, 2), newimage(row, column, 3)]; 

%% 4. track painted nail movement 
xyPixelMat = zeros(numberOfFrames,2);  xyPixelMat(1,:) = starting_point; 
xyRealMat =  zeros(numberOfFrames,2);  xyRealMat(1,:) = [xyPixelMat(1)/len_pixel*len_real, xyPixelMat(1,2)/len_pixel*len_real];  
BBMat = zeros(numberOfFrames,4); BBMat(1,:) = [xyPixelMat(1,:),17,6];

isRegionFind=0;
figure;
% Read one frame at a time, and find specified color.
for k = [1:numberOfFrames]
    
    % subplot1: plot in xy axis
    hImage=subplot(1,10,[2:9]); 
    oriFrame=imread(FileListAll(k).name);
    [thisFrame] = PicTrans(moving_points, fixed_points, oriFrame);
    imshow(thisFrame);
    
	rVal = thisFrame(:,:,1);
	gVal = thisFrame(:,:,2);
	bVal = thisFrame(:,:,3);
    
    binaryH = rVal >=175 & rVal <=290;
    binaryS = gVal >=70 & gVal <=90;
    binaryV = bVal >=35 & bVal <=50;
	
	% Overall color mask is the AND of all the masks.
	coloredMask = binaryH & binaryS & binaryV;
	% Filter out small blobs.
	coloredMask = bwareaopen(coloredMask, 100);
	% Fill holes
	coloredMask = imfill(coloredMask, 'holes');
        
	[labeledImage, numberOfRegions] = bwlabel(coloredMask);
    
	if numberOfRegions >= 1
		stats = regionprops(labeledImage, 'BoundingBox', 'Centroid');
		% Delete old texts and rectangles
		if exist('hRect', 'var')
			delete(hRect);
		end
		if exist('hText', 'var')
			delete(hText);
		end
		
		% Display the original image again.
		imshow(thisFrame);
        if k>=2
            xrange = xlim; yrange = ylim; 
            xtickrange = [xrange(1):(xrange(2)-xrange(1))/4:xrange(2)];
            ytickrange = [yrange(1):(yrange(2)-yrange(1))/4:yrange(2)];
            set(gca,'xtick',xtickrange, 'xticklabel',xtickrange / len_pixel * len_real);
            set(gca,'ytick',ytickrange, 'yticklabel',ytickrange / len_pixel * len_real);
        end
		axis on;
		hold on;
 		drawnow;
        
        
        if k==1
            thisCentroid(1) = xyPixelMat(1,1);  thisCentroid(2) = xyPixelMat(1,2);                
            thisBB = BBMat(1,:);
            hRect(1) = rectangle('Position', thisBB, 'EdgeColor', 'r', 'LineWidth', 2);               
            hSpot = plot(thisCentroid(1), thisCentroid(2), 'y+', 'MarkerSize', 10, 'LineWidth', 2);
            hText(1) = text(thisCentroid(1), thisCentroid(2)-20, strcat('X: ', num2str(xyRealMat(k,1)), '    Y: ', num2str(xyRealMat(k,2))));
            set(hText(1), 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
            isRegionFind=1;
        elseif k>1 
            xyPixel_temp=[];
            for r = 1 : numberOfRegions 
                % Find location for this blob.
                thisBB = stats(r).BoundingBox;
                thisCentroid = stats(r).Centroid;     
                if abs(diff([thisCentroid(1),xyPixelMat(k-1,1)]))<800 && abs(diff([thisCentroid(2),xyPixelMat(k-1,2)]))<110
                    xyPixel_temp = [xyPixel_temp; thisCentroid(1), thisCentroid(2), abs(diff([thisCentroid(1),xyPixelMat(k-1,1)]))+abs(diff([thisCentroid(2),xyPixelMat(k-1,2)]))];
                end
            end   
            dif_array = xyPixel_temp(:,3);
            [~,posi] = min(dif_array);
            thisCentroid = xyPixel_temp(posi,1:2);
            thisBB = [thisCentroid, 17, 6];
            
            xyPixelMat(k,:) = [thisCentroid(1), thisCentroid(2)];
            xyRealMat(k,:) = [thisCentroid(1)/len_pixel*len_real, thisCentroid(2)/len_pixel*len_real];
            BBMat(k,:) = thisBB;                      
            %x_last = xyPixelMat(k,1); y_last = xyPixelMat(k,1); lastBB = thisBB;
            hRect(r) = rectangle('Position', thisBB, 'EdgeColor', 'r', 'LineWidth', 2);
            hSpot = plot(thisCentroid(1), thisCentroid(2), 'y+', 'MarkerSize', 10, 'LineWidth', 2);
            hText(r) = text(thisBB(1), thisBB(2)-20, strcat('X: ', num2str(xyRealMat(k,1)), '    Y: ', num2str(xyRealMat(k,2))));
            set(hText(r), 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
            isRegionFind =1; 
%             set(gca,'xtick',xtickrange, 'xticklabel',xtickrange / len_pixel * len_real);
%             set(gca,'ytick',ytickrange, 'yticklabel',ytickrange / len_pixel * len_real);
        end
        
        if isRegionFind==0 && k~=1
            thisCentroid(1) = xyPixelMat(k-1,1);  thisCentroid(2) = xyPixelMat(k-1,2);
            thisBB = BBMat(k-1,:);
            xyPixelMat(k,:) = [thisCentroid(1), thisCentroid(2)];
            xyRealMat(k,:) = [thisCentroid(1)/len_pixel*len_real, thisCentroid(2)/len_pixel*len_real];
            BBMat(k,:) = thisBB; 
            hRect(r) = rectangle('Position', thisBB, 'EdgeColor', 'r', 'LineWidth', 2);
            hSpot = plot(thisCentroid(1), thisCentroid(2), 'y+', 'MarkerSize', 10, 'LineWidth', 2);
            hText(r) = text(thisBB(1), thisBB(2)-20, strcat('X: ', num2str(xyRealMat(k,1)), '    Y: ', num2str(xyRealMat(k,2))));
            set(hText(r), 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        end
            
        if k>=2
            set(gca,'xtick',xtickrange, 'xticklabel',xtickrange / len_pixel * len_real);
            set(gca,'ytick',ytickrange, 'yticklabel',ytickrange / len_pixel * len_real);
        end
            
		hold off
		drawnow;       
    end   
    isRegionFind=0;
    
    xrange = xlim; yrange = ylim;
    axis on;
	caption = sprintf('Original RGB image, frame #%d 0f %d', k, numberOfFrames);
	title(caption, 'FontSize', fontSize);
	drawnow;
    
    if k == 1
		% Enlarge figure to full screen.
		set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
		% Give a name to the title bar.
		set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 
		hCheckbox = uicontrol('Style','checkbox',... 
			'Units', 'Normalized',...
			'String', 'Finish Now',... 
			'Value',0,'Position', [.2 .96 .4 .05], ...
			'FontSize', 14);
	end
    
    	% See if they want to bail out
	if get(hCheckbox, 'Value')
		% Finish now checkbox is checked.
		msgbox('Done with demo.');
		return;
	end
	
end
msgbox('Done with tracking.');

%% 5. plot position and velocity traces
sf_video=200;

vel=[0];
for eid = 2:length(xyRealMat(:,1))
    vel = [vel, sqrt( (xyRealMat(eid,1) - xyRealMat(eid-1,1)).^2 + (xyRealMat(eid,2) - xyRealMat(eid-1,2)).^2)/(1/sf_video)] ;
end

xy_len = 1:length(xyRealMat(:,1)); 
figure; 
subplot(221); hold;
plot(xy_len/sf_video, xyRealMat(:,1),'col','k','LineWidth',2); ylabel('x position'); box off;  

subplot(222); hold; 
plot(xy_len/sf_video, xyRealMat(:,2),'col','k','LineWidth',2); ylabel('y position diff'); box off;

subplot(223); hold;
plot(xy_len/sf_video, vel,'col','k','LineWidth',2); ylabel('velocity'); box off; xlabel('t(s)');

subplot(224); hold;
dist_array = sqrt( (xyRealMat(:,1)-center_point(1)).^2 + (xyRealMat(:,2)-center_point(2)).^2 );
plot(xy_len/sf_video, dist_array,'col','k','LineWidth',2); ylabel('distance from center'); box off; xlabel('t(s)');

set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',15,'FontWeight','Bold', 'LineWidth', 2);

%% 6. import force data (through 'importdata' under the home menu) and find the t delay between force and velocity data
sf_force=63; 
%rename the force data file into 'touch'
%touch = BumpyPolyesterexplorationA; 
f_x = touch(:,1)-touch(1,1);  
f_y = touch(:,2)-touch(1,2); 

f_xy = sqrt(f_x.^2 + f_y.^2);
torq_x = touch(:,4)-touch(1,4); torq_y = touch(:,5)-touch(1,5); torq_z = touch(:,6)-touch(1,6);
d_xy = torq_z./f_xy; 

figure; plot(t_array,f_xy);

% find t delay
figure; subplot(211); 
plot((1:length(vel))/sf_video, vel,'col','k','LineWidth',2); xlabel('t');
subplot(212); 
plot((1:length(f_xy))/sf_force, f_xy,'col','k','LineWidth',2); xlabel('t');

dots=[];
dots(:,1) = [1.49,1.77,2.08,2.395,2.705]; %this data are read from the peaks of the finger taps used to align the two data set
dots(:,2) = [1.048,1.333,1.651,1.952,2.27];

figure;hold;
for eid = 1:size(dots,1)
    scatter(dots(eid,1),dots(eid,2),100,'k.');
end

t_delay = mean(dots(:,2)-dots(:,1));

%% 7. plot force and xy position from video on the same subplot
x_off = -t_delay; 
figure; hold; 
plot([1:length(vel)]/sf_video, vel,'col','k','LineWidth',2); xlabel('t');

t_len = length(f_xy);
plot(x_off+(1:t_len)/sf_force,20*f_xy ,'col','r','LineWidth',2); 
xrange = xlim;

plot(x_off+(1:t_len)/sf_force,50*d_xy+20 ,'col','g','LineWidth',2); 
%set(gca,'xtick',[0:200:xrange(2)],'xticklabel',[0:200/sf_force:xrange(2)/sf_force]); xlabel('time (s)');
legend({'velocity','xy force'}); legend box off


%% investigate torque
f_xy = sqrt(f_x.^2 + f_y.^2);
d_xy = torq_z./f_xy; 
figure; subplot(311); plot(f_xy); subplot(312); plot(torq_z); subplot(313); plot(d_xy);

z_mat = [torq_z, torq_z];
figure;
scatter3(f_x, f_y, torq_z);

figure; plot(torq_z);

%% find center by using the crosses of two xy force directions when torq z is 0
torq_z_min_array = abs(torq_z);
[sortedVals,indexes] = sort(torq_z_min_array);
t_touch_array =  x_off + [1:length(touch)]*(1/sf_force);
t_video_array = [1:length(vel)]*(1/sf_video);
i1 = indexes(2); i2 = indexes(3);
t_touch_p1 = t_touch_array(i1);  t_touch_p2 = t_touch_array(i2);
f1_x = f_x(i1);  f1_y = f_y(i1); f2_x = f_x(i2); f2_y = f_y(i2); 
torq1_z = torq_z(i1); torq2_z = torq_z(i2); %sanity check for z torque

[minValue1,I1] = min(abs(t_video_array - t_touch_p1));
[minValue2,I2] = min(abs(t_video_array - t_touch_p2));
t_video_p1 = t_video_array(I1); t_video_p2 = t_video_array(I2);
p1_x = xyPixelMat(I1,1); p1_y = xyPixelMat(I1,2);
p2_x = xyPixelMat(I2,1); p2_y = xyPixelMat(I2,2);

%calculate center position
k1 = f1_y/f1_x; k2 = f2_y/f2_x; %slope of a point equals fy/fx
center_x = 1/(k1+k2) * (p2_y - p1_y +k1*p1_x+k2*p2_x)
center_y = k1*(center_x - p1_x)+p1_y

figure; 
imshow(newimage);hold;
plot(center_x, center_y,'r*','MarkerSize',25);
plot(xyPixelMat(1,1), xyPixelMat(1,2),'g*','MarkerSize',25);

%% 8. save data
save('12_9_Q_snowflake2_tracking.mat');

%% Anton's request: plot xy surface tangential force
torq_z = touch(:,6)-touch(1,6);
t_video = [1:length(vel)]* (1/sf_video);
d_array=[]; torq_z_adjusted =[];
for tid = 1:length(torq_z)
    t_temp = x_off + tid*(1/sf_force);
    f_temp = torq_z(tid);
    i0 = find(t_video<=t_temp,1,'last');
    t0 = t_video(i0); t1 = t_video(i0+1);
    d_temp = (dist_array(i0)+dist_array(i0+1)) * (t_temp/(t0+t1));
    d_array = [d_array,d_temp];    
    torq_z_adjusted = [torq_z_adjusted, torq_z(tid)/d_temp];
end

figure;
subplot(221); plot((1:t_len)/sf_force, f_x,'col','k','LineWidth',2); ylabel('x force'); box off

subplot(222); plot((1:t_len)/sf_force, f_y,'col','k','LineWidth',2); ylabel('y force'); box off

subplot(223); plot((1:t_len)/sf_force, torq_z,'col','k','LineWidth',2); ylabel('z torque'); box off

subplot(224); plot((1:t_len)/sf_force, sqrt((f_x.^2 + f_y.^2)) + torq_z_adjusted,'col','r','LineWidth',2); ylabel('tangential force'); box off

sgtitle('BumpyPolyester A');

set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',15,'FontWeight','Bold', 'LineWidth', 2);

figure; 
subplot(121); plot((1:t_len)/sf_force, torq_z_adjusted,'col','r','LineWidth',2); ylabel('corrected z torque'); box off
subplot(122); plot((1:t_len)/sf_force, sqrt((f_x.^2 + f_y.^2)) + torq_z_adjusted,'col','r','LineWidth',2); ylabel('tangential force'); box off
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',15,'FontWeight','Bold', 'LineWidth', 2);
