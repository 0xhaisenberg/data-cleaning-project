
```{r}
install.packages("downloader")

library(downloader)
library(dplyr)
library(data.table)
library(tidyr)

## Data download and unzip 

# string variables for file download
fileName <- "UCIdata.zip"
url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir <- "UCI HAR Dataset"

# File download verification. If file does not exist, download to working directory.
if(!file.exists(fileName)){
        download.file(url,fileName, mode = "wb") 
}

# File unzip verification. If the directory does not exist, unzip the downloaded file.
if(!file.exists(dir)){
	unzip("UCIdata.zip", files = NULL, exdir=".")
}
```

```{r}
## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Read Data
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")

```

## 1. Merges the training and the test sets to create one data set

```{r}
X <- rbind(x_train, x_test)

Y <- rbind(y_train, y_test)

subject <- rbind(subject_train, subject_test)

```

## 2: Extracts only the measurements on the mean and standard deviation for each measurement.

```{r}
# Create a vector of only mean and std, use the vector to subset.

MeanStdOnly <- grep("mean()|std()", features[, 2]) 
X <- X[,MeanStdOnly]

```

```{r}

```

## 3. Appropriately labels the data set with descriptive activity names

```{r}

# Create vector of "Clean" feature names by getting rid of "()" apply to the dataSet to rename labels.

CleanFeatureNames <- sapply(features[, 2], function(x) {gsub("[()]", "",x)})
names(X) <- CleanFeatureNames[MeanStdOnly]

# combine test and train of subject data and Y data, give descriptive labels
subject <- rbind(subject_train, subject_test)
names(subject) <- 'subject'
Y <- rbind(y_train, y_test)
names(Y) <- 'activity'

# combine subject, Y, and mean and std only data set to create final data set.
X <- cbind(subject,Y, X)


```

## 4. Uses descriptive activity names to name the activities in the data set

```{r}

# group the activity column of dataSet, re-name lable of levels with activity_levels, and apply it to dataSet.

act_group <- factor(X$Y)
levels(act_group) <- activity_labels[,2]
X$Y <- act_group

```

## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.


```{r}
FinalData <- X %>%
    group_by(subject, Y) %>%
    summarise_all(list(mean))
write.table(FinalData, "FinalData.txt", row.name=FALSE)
```

