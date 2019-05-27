# Classroom-Event-Detection
In this repository the events in the classroom like sit, stand, walk and fight are detected and labelled.

The Demo.ipynb stores the code scripts required to get prediction for the Demo videos.

## Requirements
### Programming tools: Python, Matlab, Visual Studio
	Version of Pyhton: python 3.5
	Version of Matlab: Matlab R2017A
	Version of Visual Studio: Visual Studio Professional 2015
	Open source: YOLO, MEEM Tracker
	
### STEPS
	Install python 3.5, matlab R2017A, visual studio 2015, Cmake.
	Download binaries for opencv3.0 and opencv_contrib3.0.
	Build binaries using cmake and visual studio.
	Download mexopencv3.0 and run the matlab command to link python.
	Place Data in videos folder and select the file when the prompt shows up.

## Model Steps
	**Step1: Extract the frames from the video files and store it in directory.**

	*   One frame every third frame is extracted.
	*   10 such frames(F0 - F9) are extracted and stored ina directory named a0.
	*   Next 10 frames(F1 - F10) are stored in directory a1...and so on until frames are there in video.

	The frames are stored in a seperate directory called Demo with structure a{0-9}/img/img0 till img9.

	**Step1: Extract the frames from the video files and store it in directory.**

	*   One frame every third frame is extracted.
	*   10 such frames(F0 - F9) are extracted and stored ina directory named a0.
	*   Next 10 frames(F1 - F10) are stored in directory a1...and so on until frames are there in video.

	The frames are stored in a seperate directory called Demo with structure a{0-9}/img/img0 till img9.
	
	





