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