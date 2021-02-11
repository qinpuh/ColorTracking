
%% 1. load the first image frame and ask the user to locate the painted nail to get its RGB values
%MyPath = '\\bensmaia-lab\LabSharing\TextureForce\experiment 2020-12-23\camera_data\experiment_2020_12_23_15_13_47\cam19194013\denimqp_gain20';

%get Path of where pictures are saved
MyPath =  uigetdir('\\bensmaia-lab\LabSharing\TextureForce','Qinpu is waiting for your path?');

cd(MyPath);

%% get which frames to look at
prompt = {'Which frame did painted nail FIRST appear on texture board?', 'Which frame did painted nail LAST appear on texture board?'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'50','800'};
f_ans = inputdlg(prompt,dlgtitle,dims,definput);
firstFrame = str2num(f_ans{1}); lastFrame = str2num(f_ans{2});

%get the real length of the texture board in mm
prompt = {'What is the real length of one side of the texture board in mm?'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'25'};
len_ans = inputdlg(prompt,dlgtitle,dims,definput);
realLength = str2num(cell2mat(len_ans));

%% run tracking code
ifsaveCSV = 0; 
[xyPixelMat,xyRealMat, FileListAll,moving_points, fixed_points, center_point] = TrackPaintedNail(MyPath, firstFrame, lastFrame, realLength, ifsaveCSV);

%% plot markers on every frame
plot_MarkerOnNail(FileListAll, moving_points, fixed_points, xyPixelMat); 

%% plot velocity traces
[vel] = plot_velocity(xyRealMat, center_point);

%% align and plot force traces
[t_delay, f_xy, d_xy] = alignForceVelocityTraces(vel, touch);

%% plot force and aligned velocity traces on the same figure
plot_VelandForce(vel, f_xy, d_xy, t_delay)


