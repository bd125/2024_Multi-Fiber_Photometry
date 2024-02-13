Author: Bing Dai, 2023/9/14
Code tested by MATLAB2023a
Copyright: New York University Langone Health Dayu Lin Lab

Due to space limitations on GitHub, you can download the example videos from: https://zenodo.org/doi/10.5281/zenodo.8428784

1_Example_Video_SEQ_Format: A seq format video with masks and extracted data
2_Example_Video_MP4_Format: A mp4 format video with masks and extracted data
3_Dependency: add this foloder and subfolders in MATLAB pathway before running code
4_Code: 

	For seq video: 
	Dependency: BehaviorAnnotation and vislabels
	MFR_Mask_for_seq.m: generate masks for seq video
	MFR_Extraction_for_seq.m: extract data from recording video based on the masks

	For mp4 video:
	Dependency: vislabels
	MFR_Mask_for_mp4.m: generate masks for mp4 video
	MFR_Extraction_for_mp4.m: extract data from recording video based on the masks

1. Add "3_Dependency" folder to MATLAB path, and install MATLAB Image Processing toolbox and MATLAB Bioinformatics toolbox.
2. Generate masks using code "MFR_Mask_for_seq.m" or "MFR_Mask_for_mp4.m" in the folder "4_Code".
3. Extract recording data using code "MFR_Extraction_for_seq.m" or "MFR_Extraction_for_mp4.m" in the folder "4_Code".

Note: the video paths in all the codes need to modified based on the location of your vidoes.  