% MATLAB code to align behavioral recording with neuronal recording
% Input: 
%       matfile: file path of the recording data extracted
%       topVideo: file path of the top camera for behavioral recording
%       
% Output: 
%       a groups of arrays saved in '#VIDEO_NAME#_data_fix.mat'
%    	FL: number of video frames per second;
%       LMag: raw fluorescent intensity extracted from each channel;
%       Lflat: flattened the raw fluorescent intensity
%       Lfilter: precentage fluorescent change after flattening, dF/F
%       nRois: number of regions
%       regionName: name of each channel
%
% $Author: Bing Dai & Dayu Lin$    $Date: 13-Dec-2023 21:26:20 $    $Revision: 1.0 $
% Code tested in MATLAB2023a
% Copyright: New York University Langone Health Dayu Lin Lab

%% Video and recording file path

% file path of the behavior video in .seq file, .mp4 file is not supported
behaviorvideo = 'R:\linlab\linlabspace\Bing\Paper\2023_MultiFiber\2_Revision\3_Code\MFR_Examples_v2\1_Example_Video_SEQ_Format\Example_behavior_top.seq';  % MODIFY THIS LINE!!!
% file path of the recording video in .seq format
reVideo = 'R:\linlab\linlabspace\Bing\Paper\2023_MultiFiber\2_Revision\3_Code\MFR_Examples_v2\1_Example_Video_SEQ_Format\Example_recording_video.seq';   % MODIFY THIS LINE!!!


% file path of the extracted recording data
matfile = 'R:\linlab\linlabspace\Bing\Paper\2023_MultiFiber\2_Revision\3_Code\MFR_Examples_v2\1_Example_Video_SEQ_Format\Example_recording_video_data.mat'; % MODIFY THIS LINE!!!

% file name of the fixed data
matfile_fix = regexprep(matfile,'_data.mat','_data_fix.mat');
%%
% load the recording data
load(matfile, 'FL', 'LMag', 'Lfilter','Lflat','nRois', 'regionName');

% Extract the time stamp and make alignment
info = seqIo(behaviorvideo, 'getInfo' );
if info.numFrames ~= length(LMag)
    sr = seqIo(reVideo, 'reader');
    camt=sr.getts(); 
    camt = camt-camt(1);
    sr = seqIo(behaviorvideo, 'reader');
    topt=sr.getts();
    topt = topt-topt(1);
    LMag_fix = nan(size(LMag, 1), length(topt));
        for m = 1:length(topt)
            [~, idx]=min(abs(camt-topt(m)));
            LMag_fix(:,m) = LMag(:,idx);
        end
end

iRois = 1; % index for data extraction
Lflat_fix = []; % flattened the raw fluorescent intensity
Lbackground_fix = []; % baseline fluorescent intensity
Lfilter_fix = []; % precentage fluorescent change, dF/F
NAindex = strcmp(regionName, 'NA'); % find the index of the unassgined channels
    
for i = 1:nRois
    if ~NAindex(i) % extract data if the region is not unassigned 
            % extract the background of each channel and calculate the dF/F
            % value in Lfilter. Data is flatten by using function msbackadj
            % with 10s window.
            timeWindow = 10;
            Lflat_fix(iRois,:) = zeros(size(LMag_fix(iRois,:)));
            W = floor(length(LMag_fix(iRois,:))/FL/10);
            Lflat_fix(iRois, ceil(timeWindow*FL):end) = msbackadj((ceil(timeWindow*FL)/FL:1/FL:length(LMag_fix(iRois,:))/FL)', ...
                LMag_fix(iRois,ceil(timeWindow*FL):end)', 'StepSize', W, 'windowsize', W,'SHOWPLOT',0);
            Lbackground_fix(iRois,:) = LMag_fix(iRois,:)-Lflat_fix(iRois,:);
            Lfilter_fix(iRois,:) = Lflat_fix(iRois,:)./Lbackground_fix(iRois,:);
            
            iRois = iRois + 1;
    end
end

% save the fixed data in .mat format
save(matfile_fix, 'FL', "LMag_fix",'LMag','Lfilter_fix', 'Lfilter',"Lflat_fix",'Lflat','nRois', 'regionName');