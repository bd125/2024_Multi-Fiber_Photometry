% MATLAB code to generate a mask of MFP recording video
% Input video format: .seq
% Output: a binary mask saved in '#VIDEO_NAME#_mask.mat'

% $Author: Bing Dai $    $Date: 12-Sep-2023 15:03:55 $    $Revision: 1.0 $
% Code tested in MATLAB2023a
% Copyright: New York University Langone Health Dayu Lin Lab

%% video path
reVideo = 'R:\linlab\linlabspace\Bing\Paper\2023_MultiFiber\3_MFR_Examples_v1\1_Example_Video_SEQ_Format\Example_recording_video.seq';
%% generate mask or load mask

% file name of the mask
maskFile = regexprep(reVideo,'.seq','_mask.mat');
 
% read the first frame of the video 
sm = seqIo(reVideo, 'reader');
sm.seek(0);                                                              
[aFrame,~] = sm.getframe();

% illustrate the first frame
figure;
imshow(aFrame);

% adjust the contrast of the image
aFrame_correct =imadjust(aFrame,[0 0.1],[],1.2);  % adjust the parameters as needed
figure;
imshow(aFrame_correct);

% threshold the image to separate bright circles from the background

threshold = 50; % adjust this threshold value as needed
aFrame_final = aFrame_correct > threshold;
figure;
imshow(aFrame_final);

% identify different channels
[centers, radii, metric] = imfindcircles(aFrame_final,[15 30]);

% generate a mask
mask = zeros(492, 656);
for i = 1:length(centers)
roi = drawcircle('Center',centers(i,:),'Radius',min(radii),'StripeColor','red');
maskTemp = createMask(roi);
mask = maskTemp | mask;
end
sm.close();

% save the mask 
save(maskFile, 'mask');

% load mask
load(maskFile);
[labels, nRois] = bwlabel(mask);
figure; vislabels(labels);
