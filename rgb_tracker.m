
%% 1. load the first image frame and ask the user to locate the painted nail to get its RGB values
%MyPath = '\\bensmaia-lab\LabSharing\TextureForce\experiment 2020-12-23\camera_data\experiment_2020_12_23_15_13_47\cam19194013\denimqp_gain20';
MyPath =  uigetdir('\\bensmaia-lab\LabSharing\TextureForce','Qinpu is waiting for your path?');
cd(MyPath);
FileListAll = dir('*.jpeg');
for k = 1 : length(FileListAll) %somtimes the name in the origianl folder is not in sequence 
    FileListAll(k).sortkey = str2double(regexp(FileListAll(k).name, 'image(\d+).jpeg', 'tokens', 'once'));
end
T = struct2table(FileListAll);
sortedT = sortrows(T, 'sortkey');
sortedS = table2struct(sortedT);

FileList = sortedS;
FileListAll = FileList(1:end);
numberOfFrames = length(FileListAll);

%% 1.1. if painted nail did not appear in the first frame, find the frame that the colored nail appeared first
%which frame to extract nail color from (checked manually)
prompt = {'Which frame did painted nail FIRST appear on texture board?', 'Which frame did painted nail LAST appear on texture board?'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'25','1000'};
f_ans = inputdlg(prompt,dlgtitle,dims,definput);
fsid = str2num(f_ans{1}); fnid = str2num(f_ans{2});

FileListAll = FileListAll(fsid:fnid);
numberOfFrames = length(FileListAll);

%% 2. plot the first frame and prompt the user to click the four corners 
%of the first frame and transform it to make it parrallel to the camera
x=[]; y=[]; fontSize = 24;
fig1 = figure;
hImage=subplot(1,1,1);

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
  if numPointsClicked == 4
    % Exit loop if
    break;
  end
end
msgbox('Done collecting points');
pause(0.5); close(fig1);
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
fig2 = figure;
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
pause(0.5); close(fig2);
pause(0.5);
prompt = {'What is the real length of one side of the texture board in mm?'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'25'};
len_ans = inputdlg(prompt,dlgtitle,dims,definput);
len_real = str2num(cell2mat(len_ans));
len_pixel = x(2)-x(1);
starting_point = [x(3), y(3)];
center_point = [x(4),y(4)];

%painted nail
% vals = [double(newimage(int32(y(3)),int32(x(3)),:))];
% redThresh = vals(1)/255; greenThresh = vals(2)/255; blueThresh = vals(3)/255;

%% Find RGB markers and track them from video
redThresh = 0.2; % Threshold for red detection

hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true', ...
                                'MinimumBlobArea', 20, ...
                                'MaximumCount', 50);
hshapeinsWhiteBox = vision.ShapeInserter('BorderColor', 'Custom', ...
                                        'CustomBorderColor', [1 0 0]); % Set white box handling                                    
                                   
xyPixelMat = zeros(numberOfFrames, 2); %initialize matrix for holding tracked xy position in pixels
xyRealMat = zeros(numberOfFrames, 2); %initialize matrix for holding tracked xy position in real unit (mm)

xyPixelMat(1,:) = [starting_point]; 
xyRealMat(1,:) = [xyPixelMat(1,1)/len_pixel*len_real, xyPixelMat(1,2)/len_pixel*len_real];

for t = 2:numberOfFrames  %the first frame is already saved 
    
    oriFrame=imread(FileListAll(t).name);
    [rgbFrame] = PicTrans(moving_points, fixed_points, oriFrame);
    diffFrameRed = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the image
    diffFrameRed = medfilt2(diffFrameRed, [3 3]); % Filter out the noise by using median filter
    binFrameRed = im2bw(diffFrameRed, redThresh); % Convert the image into binary image with the red objects as white 
      
    [thisCentroid, bboxRed] = step(hblob, binFrameRed); % Get the centroids and bounding boxes of the red blobs    
    
    for cid = 1:size(thisCentroid,1)
        if abs(diff([thisCentroid(cid,1),xyPixelMat(t-1,1)]))<310 && abs(diff([thisCentroid(cid,2),xyPixelMat(t-1,2)]))<250
            xyPixelMat(t,:) = [thisCentroid(cid,1), thisCentroid(cid,2)];
            xyRealMat(t,:) = [thisCentroid(cid,1)/len_pixel*len_real, thisCentroid(cid,2)/len_pixel*len_real];
        end
    end
end
    
%% sanity check that the saved tracked position is correct 
close all; 
k = 410; % a random frame number up to you to pick
oriFrame=imread(FileListAll(k).name);
[rgbFrame] = PicTrans(moving_points, fixed_points, oriFrame);
rgbFrameGrey = rgb2gray(rgbFrame);
rgbFrameout = insertShape(rgbFrameGrey, 'FilledCircle',[xyPixelMat(k,1), xyPixelMat(k,2), 25],'color','r');
figure;
subplot(221); imshow(rgbFrame); subplot(222); imshow(rgbFrameGrey); subplot(2,2,[3,4]); imshow(rgbFrameout);  


%% if painted nail ever failed to get detected on a certain frame from the previous sanity check section
k = 407;

oriFrame=imread(FileListAll(k).name);
[rgbFrame] = PicTrans(moving_points, fixed_points, oriFrame);
diffFrameRed = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the image
diffFrameRed = medfilt2(diffFrameRed, [3 3]); % Filter out the noise by using median filter
binFrameRed = im2bw(diffFrameRed, redThresh); % Convert the image into binary image with the red objects as white 
[thisCentroid, bboxRed] = step(hblob, binFrameRed); % Get the centroids and bounding boxes of the red blobs    

figure;
rgbFrameout = rgb2gray(rgbFrame);
imshow(rgbFrameout);  hold;
for cid = 1:size(thisCentroid,1)
    plot(thisCentroid(cid,1), thisCentroid(cid,2), 'r.', 'MarkerSize',20);
end

title(['Frame ', num2str(k)]);

%%
save('denimqp_gain20.mat');

%% 5. plot position and velocity traces
sf_video=200;
xy_len = 1:length(xyRealMat(:,1)); 

vel=[0];
for eid = 2:length(xyRealMat(:,1))
    vel = [vel, sqrt( (xyRealMat(eid,1) - xyRealMat(eid-1,1)).^2 + (xyRealMat(eid,2) - xyRealMat(eid-1,2)).^2)/(1/sf_video)] ;
end

figure; 
plot(xy_len/sf_video, vel,'col','k','LineWidth',2); ylabel('velocity'); box off; xlabel('t(s)');


ind_end = find(xyPixelMat(:,1)==0,1,'first');

figure; 
subplot(121); hold;
plot(xy_len/sf_video, xyRealMat(:,1),'col','k','LineWidth',2); ylabel('x position'); box off;  

subplot(122); hold; 
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


% find t delay
figure; subplot(211); 
plot((1:length(vel))/sf_video, vel,'col','k','LineWidth',2); xlabel('t'); ylim([0 500]);
subplot(212); 
plot((1:length(f_xy))/sf_force, f_xy,'col','k','LineWidth',2); xlabel('t');

% dots=[];
% dots(:,1) = [1.49,1.77,2.08, 3.85,8.24]; %this data are read from the peaks of the finger taps used to align the two data set
% dots(:,2) = [2.5, 3.95, 5.3, 6.3, 13.4];
% 
% figure;hold;
% for eid = 1:size(dots,1)
%     scatter(dots(eid,1),dots(eid,2),100,'k.');
% end
% 
% t_delay = mean(dots(:,2)-dots(:,1));

%% 7. plot force and xy position from video on the same subplot
%x_off = -t_delay;
x_off=0;
figure; hold; 
plot([1:length(vel)]/sf_video, vel,'col','k','LineWidth',2); xlabel('t');

t_len = length(f_xy);
plot(x_off+(1:t_len)/sf_force,20*f_xy ,'col','r','LineWidth',2); 
xrange = xlim;

plot(x_off+(1:t_len)/sf_force,50*d_xy+20 ,'col','g','LineWidth',2); 
%set(gca,'xtick',[0:200:xrange(2)],'xticklabel',[0:200/sf_force:xrange(2)/sf_force]); xlabel('time (s)');
legend({'velocity','xy force'}); legend box off


