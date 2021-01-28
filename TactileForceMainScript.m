
%% 1. load the first image frame and ask the user to locate the painted nail to get its RGB values
%MyPath = '\\bensmaia-lab\LabSharing\TextureForce\experiment 2020-12-23\camera_data\experiment_2020_12_23_15_13_47\cam19194013\denimqp_gain20';

%get Path of where pictures are saved
MyPath =  uigetdir('\\bensmaia-lab\LabSharing\TextureForce','Qinpu is waiting for your path?');

%get which frames to look at
prompt = {'Which frame did painted nail FIRST appear on texture board?', 'Which frame did painted nail LAST appear on texture board?'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'25','1000'};
f_ans = inputdlg(prompt,dlgtitle,dims,definput);
firstFrame = str2num(f_ans{1}); lastFrmae = str2num(f_ans{2});

%get the real length of the texture board in mm
prompt = {'What is the real length of one side of the texture board in mm?'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'25'};
len_ans = inputdlg(prompt,dlgtitle,dims,definput);
len_real = str2num(cell2mat(len_ans));

%run tracking code
[xyPixelMat,xyRealMat] = TrackPaintedNail(MyPath, firstFrame, lastFrame, realLength);
