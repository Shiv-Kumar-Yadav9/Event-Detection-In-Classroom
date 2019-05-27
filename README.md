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
### Step1: Extract the frames from the video files and store it in directory.

	*   One frame every third frame is extracted.
	*   10 such frames(F0 - F9) are extracted and stored ina directory named a0.
	*   Next 10 frames(F1 - F10) are stored in directory a1...and so on until frames are there in video.

	The frames are stored in a seperate directory called Demo with structure a{0-9}/img/img0 till img9.

### Step 2: Detect individual person in each frame and get the coordinates of the person in the frame.

	*  In this step the coordinates of each person is detected using the open source libraray called YOLO.

	* Person is searched for and detected in frame 0 ( F0 ) of each directory ,i.e. for each a{0-9}.

	*   The detected coordinates of the humans are then stored in a{0-9} folder in a .txt file named as person{0-9}.txt, where person0 stores the coordinates of first person in frame 0 ( F0 ) and person1 stores coordinates of second person in frame 0 ( F0 ) and so on...

### Step 3: Track the coordinates of the person in the next 9 frames of the image set.

	*   MEEM tracker is used to detect the coordinates of the humans in the next 10 frames of the image set.
	*   It accepts the coordinates of the person in frame 0 ( F0 ), the initial frame ( F0 ) and the folder containing the set of 10 frames.
	*   It returns the tracked coordinates of that person in next 10 frames.
	*   Each output{0-9}.txt file containing the coordinates of the person in other 10 frames corresponds to every input{0-9}.txt files which contain the coordinates of person in first frame ( F0 ).
	NOTE: You need to place the MEEM tracker code in the same current directory.

### Step 4: Extract the person out of all 10 frames.

	* The output file of MEEM tracker output{0-9}.txt contains the coordinates of the person{0-9} in all 10 frames that was detected in the YOLO stage.   

	*   The region bounded by the output{0-9}.txt files is cropped out from each 10 images and saved into a subfolder res{0-9}.

	*   Each individual person have their set of extracted images pertaining to that person only.

### Step 5: Get the input feature for Demo data.


	*   Read the cropped images for each person. 
	*   The images are then reshaped to 96\*96 size and is converted into gray scale values.
	*   All the images are then concatenated together to give a structure of the shape 10 \* 96 \* 96 \* 1.
	*   This formsas input to the CNN model which gives the probabiltiy of the event occuring.

### Step 6: Labelling the images and generating video.


	1.   In this step the frame 0 ( F0 ) of all the folders is labelled with corresponding predition and the image labelled for each human detected is stored in the directory names 'res'.
	2.   The images are stored in the alphabetical order of how they occur in the video and thus have the same order in which they can be joined to form a video.
	
## Two models were compiled and trained. The models were checked to identify which model gives better accuracy.

*   One 3DCNN model that gives prediction for all the classes of events (sit, stand, walk, push) that could possibly occur.
*   Four seperate 3DCNN models that individually checked for probabilty of occurance of each of the individual class of event.

### Model 1: One model for all class of events.

	*   The model outptus the probability of the set of images to represent each of the classes of event.
	*   The event which has highest probability is selected as the event that is occuring and is selected for labelling on the image.
	*   The training and validation errors over the epochs changed like..
	![Training and Validation Losses][tv-loss]
	|[accuracy][acc]|[loss][ls]|
	|:---:|:---:|
	|Accuracy changes with epochs|Loss changes with epochs|


### Model 2: Four seperate model for each class of events.


	*   Each of the four model outptus the probability of the set of images to represent that classes of event.
	*   Out of all thet probabilities the probability which is highest is selected as the event that is occuring and is selected for labelling on the image.




<!--Images-->
[tv-loss]: misc/images/Training_and_validation_losses.png "Losses"
[acc]:misc/images/accuracy.png "Accuracy"
[ls]:misc/images/loss.png "Loss"
