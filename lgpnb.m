
moving_points = [84, 27; 29,137; 287,135; 231, 26];
fixed_points = [10,10; 10,100; 100,100; 100,10];
tform = fitgeotrans(moving_points, fixed_points, 'projective');
oldimage = imread('trapezoid.jpg');
newimage = imwarp(oldimage,tform);

figure
imshow(newimage)

%%
cd('\\bensmaia-lab\labsharing\Qinpu\TactileForce\images');
imtool('test5.jpg');
%h=gca;
%h.visible = 'On';


%% my test

moving_points = [657, 1164; 79,564; 541,177; 1059,759];
fixed_points = [10, 10; 10,100; 50,100; 50,10];
tform = fitgeotrans(moving_points, fixed_points, 'projective');
oldimage = imread('test5.jpg');
newimage = imwarp(oldimage,tform);

figure;
imshow(newimage)