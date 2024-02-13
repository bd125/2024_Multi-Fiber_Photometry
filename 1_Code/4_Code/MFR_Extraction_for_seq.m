% MATLAB code to generate a mask of MFP recording video
% Input: 
%       reVideo: file path of the recording video in .seq format
%       maskFile: file path of the mask file
% Output: 
%       a groups of arrays saved in '#VIDEO_NAME#_data.mat':
%       info: general info of the video file
%    	FL: number of video frames per second;
%       LMag: raw fluorescent intensity extracted from each channel;
%       Lflat: flattened the raw fluorescent intensity
%       Lfilter: precentage fluorescent change after flattening, dF/F
%       nRois: number of regions
%       regionName: name of each channel
%
% !!! Raw data is stored in LMag. 
% !!! When calculating the dF/F (Lfilter), we utilize the msbackadj
% function with a 10-second window to correct for photobleaching effects.
% However, it's important to note that this method might also remove slow
% transient signals on the scale of minutes. If preserving and analyzing
% these slow transients is critical for your study, we recommend using the
% LMag for further analysis to avoid loss of these slower signal dynamics.

%
% $Author: Bing Dai $    $Date: 13-Dec-2023 21:26:20 $    $Revision: 2.0 $
% Code tested in MATLAB2023a
% Copyright: New York University Langone Health Dayu Lin Lab

%%
%
%

%% Video and Mask path
% file path of the recording video in .mp4 format
reVideo = 'C:\Work\Code\5_MFR_Examples_v1\1_Example_Video_SEQ_Format\Example_recording_video.seq';   % MODIFY THIS LINE!!!
% file path of the mask file
maskFile = 'C:\Work\Code\5_MFR_Examples_v1\1_Example_Video_SEQ_Format\Example_recording_video_mask.mat';   % MODIFY THIS LINE!!!

%% Define the name of each channel based on the order of the mask
% define the name of each channel, use NA for unassgined channels
% for example:
% regionName = {'VMHvl','MeAa','PAGl','LSv','DMH','PA','AHN','NA','NA','NA','BNSTp','NA','NA','MeAp','PMv','MPOA','CoAp','NA','NA'};

regionName = {'DMH','lPAG','SUBv','PA','LSv','MPN','MeAp','VMHvl','PMv','CoAp','BNSTp','AHN','MeAa'};% MODIFY THIS LINE!!!

NAindex = strcmp(regionName, 'NA'); % find the index of the unassgined channels

%% Load mask
load(maskFile);
% View the order of each mask
[labels, nRois] = bwlabel(mask);
figure; vislabels(labels);

%% extract recording data

% file name of the extracted data
matfile = regexprep(reVideo,'.seq','_data.mat');

% generate the extracted data if it is not existed
if ~isequal(exist(matfile, 'file'), 2)
    
    % creat a wait bar to indicate the progress of the data extraction
    f = waitbar(0,'Frames:1/' + string(nFrames),'Name','Data Extracting ...');
    
    % read the recording video 
    sr = seqIo(reVideo, 'reader');
    info = sr.getinfo(); % general info of the video
    nFrames = info.numFrames; % number of frames in video stream
    FL = info.fps; % number of video frames per second

   
    % read the first frame
    sr.seek(0);                                                              
    [aFrame,~] = sr.getframe();
    
    % calculate the main values of each channel
    RoiProps = []; 
    RoiProps = regionprops(mask,aFrame,'MeanIntensity');

    for ii = 2:nFrames
        % read next frame and convert the image into greyscale
        [aFrame,~] = sr.getnext();
        % calculate the main values of each channel
        RoiProps(:,ii) = regionprops(mask,aFrame,'MeanIntensity');
        % update the wait bar
        waitbar(ii/nFrames,f,'Frames:' + string(ii) + '/' + string(nFrames));
    end

    % define arrays for data extraction
    LMag = []; % raw fluorescent intensity extracted from each channel
    Lflat = []; % flattened the raw fluorescent intensity
    Lbackground = []; % baseline fluorescent intensity
    Lfilter = []; % precentage fluorescent change, dF/F
    iRois = 1; % index for data extraction
    
    for i = 1:nRois
        if ~NAindex(i) % extract data if the region is not unassigned 
            % save the raw mean intensity in LMag
            LMag(iRois,:) = [RoiProps(iRois,:).MeanIntensity];

            % extract the background of each channel and calculate the dF/F
            % value in Lfilter. Data is flatten by using function msbackadj
            % with 10s window.
            timeWindow = 10;
            Lflat(iRois,:) = zeros(size(LMag(iRois,:)));
            W = floor(length(LMag(iRois,:))/FL/10);
            Lflat(iRois, ceil(timeWindow*FL):end) = msbackadj((ceil(timeWindow*FL)/FL:1/FL:length(LMag(iRois,:))/FL)', ...
                LMag(iRois,ceil(timeWindow*FL):end)', 'StepSize', W, 'windowsize', W,'SHOWPLOT',0);
            Lbackground(iRois,:) = LMag(iRois,:)-Lflat(iRois,:);
            Lfilter(iRois,:) = Lflat(iRois,:)./Lbackground(iRois,:);
            
            iRois = iRois + 1;
        end
    end
    regionName(NAindex) = []; % remove NA from the region name
    nRois = nRois - sum(NAindex); % correct the number of regions by removing unassgined chnannels
    % save the extracted data in .mat format
    save(matfile, 'info', 'FL', 'LMag', 'Lfilter','Lflat','nRois', 'regionName');
end

%%
load(matfile, 'FL', 'LMag', 'Lfilter','Lflat','nRois', 'regionName');

% preview the raw data 
time = (1:length(Lfilter))/25/60;
for ii = 1:nRois
    figure;
    plot(time,LMag(ii,:))
    title(regionName{ii})
    xlabel('Time (min)')
    ylabel('F')
end
