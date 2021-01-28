
function [xyPixelMat,xyRealMat] = rgbTracker(FrameSt,FrameEd,FileListAll,colorThresh, moving_points, fixed_points, xyPixelMat,xyRealMat)
hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true', ...
                                'MinimumBlobArea', 20, ...
                                'MaximumCount', 50);
hshapeinsWhiteBox = vision.ShapeInserter('BorderColor', 'Custom', ...
                                        'CustomBorderColor', [1 0 0]); % Set white box handling    
for t = FrameSt:FrameEd %the first frame is already saved 
    oriFrame=imread(FileListAll(t).name);
    [rgbFrame] = PicTrans(moving_points, fixed_points, oriFrame);
    diffFrameRed = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the image
    diffFrameRed = medfilt2(diffFrameRed, [3 3]); % Filter out the noise by using median filter
    binFrameRed = im2bw(diffFrameRed, colorThresh); % Convert the image into binary image with the red objects as white 
      
    [thisCentroid, bboxRed] = step(hblob, binFrameRed); % Get the centroids and bounding boxes of the red blobs    
    
    for cid = 1:size(thisCentroid,1)
        if abs(diff([thisCentroid(cid,1),xyPixelMat(t-1,1)]))<310 && abs(diff([thisCentroid(cid,2),xyPixelMat(t-1,2)]))<250
            xyPixelMat(t,:) = [thisCentroid(cid,1), thisCentroid(cid,2)];
            xyRealMat(t,:) = [thisCentroid(cid,1)/len_pixel*len_real, thisCentroid(cid,2)/len_pixel*len_real];
        end
    end
end