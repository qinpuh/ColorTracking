function [xyPixelMat,xyRealMat] = TrackPaintedNail(MyPath, firstFrame, lastFrame, realLength)

%MyPath =  uigetdir('\\bensmaia-lab\LabSharing\TextureForce','Qinpu is waiting for your path?');
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
% prompt = {'Which frame did painted nail FIRST appear on texture board?', 'Which frame did painted nail LAST appear on texture board?'};
% dlgtitle = 'Input';
% dims = [1 35];
% definput = {'25','1000'};
% f_ans = inputdlg(prompt,dlgtitle,dims,definput);
% fsid = str2num(f_ans{1}); fnid = str2num(f_ans{2});

FileListAll = FileListAll(firstFrame:lastFrame);
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
promptMessage = sprintf('Click the four corners in sequence from uppermost left counterclockwise', maxAllowablePoints);
numPointsClicked = 0;
[x,y] = ClickFig(numPointsClicked,maxAllowablePoints,promptMessage);
pause(0.5); close(fig1);
moving_points = [x(1),y(1); x(2),y(2); x(3),y(3); x(4),y(4)];
fixed_points = [1, 1500; 1, 1; 1500,1; 1500,1500];
tform = fitgeotrans(moving_points, fixed_points, 'projective');
newimage = imwarp(thisFrame,tform);
%figure;
%imshow(newimage); title('Transformed Image');

%% 3. Click the bottom two corners to get length in pixels; 
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
[x,y] = ClickFig(numPointsClicked,maxAllowablePoints,promptMessage);
pause(0.5); close(fig2);
%pause(0.5);

% prompt = {'What is the real length of one side of the texture board in mm?'};
% dlgtitle = 'Input';
% dims = [1 35];
% definput = {'25'};
% len_ans = inputdlg(prompt,dlgtitle,dims,definput);
% len_real = str2num(cell2mat(len_ans));

len_real = realLength; 
len_pixel = x(2)-x(1);
starting_point = [x(3), y(3)];
center_point = [x(4),y(4)];

%painted nail
% vals = [double(newimage(int32(y(3)),int32(x(3)),:))];
% redThresh = vals(1)/255; greenThresh = vals(2)/255; blueThresh = vals(3)/255;

%% Find RGB markers and track them from video
redThresh = 0.2; % Threshold for red detection                                
                                   
xyPixelMat = zeros(numberOfFrames, 2); %initialize matrix for holding tracked xy position in pixels
xyRealMat = zeros(numberOfFrames, 2); %initialize matrix for holding tracked xy position in real unit (mm)

xyPixelMat(1,:) = [starting_point]; 
xyRealMat(1,:) = [xyPixelMat(1,1)/len_pixel*len_real, xyPixelMat(1,2)/len_pixel*len_real];

FrameSt=2; FrameEd=10;
[xyPixelMat,xyRealMat] = PaintedNailTracker(FrameSt,FrameEd,FileListAll,...
    redThresh, moving_points, fixed_points, xyPixelMat,xyRealMat);


%%
%save('denimqp_gain20.mat');