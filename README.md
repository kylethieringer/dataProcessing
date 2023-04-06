# dataProcessing

## **Data Structure and Format**
```
-- dataDirectory/ 
     -- 20220517_125332_18159211_rig1_1/
         -- 000000.mp4
         -- 000000.npz
         -- daq.h5
         -- metadata.yaml
```
---
## **Tracking**

### inference
Example models can be found [**in this drive folder**](https://drive.google.com/drive/folders/1V2s6oDy6fzXHGe56tMkZHHlmRIgHG_6g?usp=sharing)
- make sure to update your model paths in the [tracking.sh](/tracking/tracking.sh) file

On the cluster:
```
$ cd /dataserver/user/dataProcessing/tracking
$ bash tracking.sh /path/to/dataDirectory/
```
This will run inference on videos then create this file:
- *000000.mp4.inference.slp*

### proofread
The next steps would be to proofread the data and save the files as:
- *000000.mp4.inference.proofread.slp*

### export
Once tracks have been proofread, you can export them as a h5 file called:
- *000000.mp4.inference.proofread.tracking.h5*

Back on the cluster:
```
$ cd /dataserver/user/dataProcessing/tracking
$ bash export.sh /path/to/dataDirectory/
```

---
## **Song Segmentation**
On the cluster:
```
$ cd /dataserver/user/dataProcessing/songSegmentation
$ bash segment.sh /path/to/dataDirectory/
```
This will segment audio using [Murthy Lab Fly Song Segmenter](https://github.com/murthylab/MurthyLab_FlySongSegmenter)

The output is one of the following:
- *daq_segmented_new.mat*
- *song.mat*

There may also be:
- *daq_filtered.mat*
- *daq_segmented_without_postProcess_params.m.mat*


## **Process Tracking and Segmentation into h5 Files**
This will create a file that has behavioral features, some song information, and vectors to sync video and audio.

Must be done after tracks have been exported and song has been segmented.

This will create a file called:
- *expt_name.h5*

On the cluster:
```
$ cd /dataserver/user/dataProcessing/createfeatures
$ bash process.sh /path/to/dataDirectory/
```