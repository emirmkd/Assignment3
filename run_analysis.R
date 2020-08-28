### Check if packages exist before installing
list.of.packages <- c("dplyr", "data.table")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

### Load packages
library(data.table)
library(dplyr)

### Download UCI datafiles and unzip them
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
  unzip(destFile)
}

### Start reading the files
setwd("./UCI HAR Dataset")

### Read the Activity files
ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)

### Read the Features files
FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)

### Read the Subject files
SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)

### Read the Activity Labels
ActivityLabels <- read.table("./activity_labels.txt", header = F)

#### Read the Feature Names
FeaturesNames <- read.table("./features.txt", header = F)

#### Merge the data files in 3 sets: Features, Subjects and Activities
FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

### Rename the columns in ActivityData & ActivityLabels
names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")

### Get factor of Activity names
Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]

### Rename the SubjectData columns
names(SubjectData) <- "Subject"

### Rename the FeaturesData columns using columns from FeaturesNames
names(FeaturesData) <- FeaturesNames$V2

### Create one large Dataset with only these variables: SubjectData,  Activity,  FeaturesData
MergedData <- cbind(SubjectData, Activity)
MergedData <- cbind(MergedData, FeaturesData)

### Create New datasets by extracting only the measurements on the mean and standard deviation for each measurement
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSetSub <- subset(MergedData, select=DataNames)

#####Rename the columns of the large dataset using more descriptive activity names
names(MergedData)<-gsub("^t", "time", names(MergedData))
names(MergedData)<-gsub("^f", "frequency", names(MergedData))
names(MergedData)<-gsub("Acc", "Accelerometer", names(MergedData))
names(MergedData)<-gsub("Gyro", "Gyroscope", names(MergedData))
names(MergedData)<-gsub("Mag", "Magnitude", names(MergedData))
names(MergedData)<-gsub("BodyBody", "Body", names(MergedData))

####Create a second, independent tidy data set with the average of each variable for each activity and each subject
TidyData<-aggregate(. ~Subject + Activity, MergedData, mean)
TidyData<-TidyData[order(TidyData$Subject, TidyData$Activity),]

#Save this tidy dataset to local file
write.table(TidyData, file = "tidydata.txt",row.name=FALSE)