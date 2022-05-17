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

## **Tracking**
```
$ cd /dataserver/user/dataProcessing/tracking
$ bash tracking.sh /path/to/dataDirectory/
```
This will run inference on videos then create 2 files: 

- *000000.mp4.inference.slp*
- *000000.mp4.inference.cleaned.slp*

The next steps would be to proofread the data and save the files as:

- *000000.mp4.inference.cleaned.proofread.slp*

Once tracks have been proofread, you can export them as an h5 file

Back on the cluster:
```
$ cd /dataserver/user/dataProcessing/tracking
$ bash export.sh /path/to/dataDirectory/
```

## **Song Segmentation**
```
$ cd /dataserver/user/dataProcessing/songSegmentation
$ bash segment.sh /path/to/dataDirectory/
```
This will segment audio using [Murthy Lab Fly Song Segmenter](https://github.com/murthylab/MurthyLab_FlySongSegmenter)

The output one of the following:
- *daq_segmented_new.mat*
- *song.mat*

## **Process Tracking and Segmentation into h5 Files**
This will create a file that has behavioral features, some song information, and vectors to sync video and audio.

Must be done after tracks have been exported and song has been segmented.
```
$ cd /dataserver/user/dataProcessing/createfeatures
$ bash process /path/to/dataDirectory/
```