#Checking for and creating directories
if(!file.exists("data")){dir.create("data")}

#Downloading files from the web
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

#Unzip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

path <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)
files


#Merging data
# Activity data
activity_train <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)
activity_test  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)


# Subject data
subject_train <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
subject_test  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

# Feature data
features_train <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)
features_test  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)

# put train and test data together
data_activity<- rbind(activity_train, activity_test)
data_subject <- rbind(subject_train, subject_test)
data_features<- rbind(features_train, features_test)

# assigning names to variables
names(data_subject)<-c("Subject")
names(data_activity)<- c("Activity")
dataFeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(data_features)<- dataFeaturesNames$V2

# Full data
subject_features <- cbind(data_subject, data_features)
DATA <- cbind(subject_features, data_activity)

# Extract mean and std deviation features
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "Subject", "Activity" )
DATA<-subset(DATA,select=selectedNames)

#Naming the activities in dataset with activity labels
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)

DATA$Activity <- factor(DATA$Activity, levels = activityLabels[,1], labels = activityLabels[,2])

#Label dataset with descriptive variable names
names(DATA)<-gsub("^t", "time", names(DATA))
names(DATA)<-gsub("^f", "frequency", names(DATA))
names(DATA)<-gsub("Acc", "Accelerometer", names(DATA))
names(DATA)<-gsub("Gyro", "Gyroscope", names(DATA))
names(DATA)<-gsub("Mag", "Magnitude", names(DATA))
names(DATA)<-gsub("BodyBody", "Body", names(DATA))

#Creating another tidy dataset
library(reshape2)
meltedData <- melt(DATA, id = c("Subject", "Activity"))
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)

write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)

#Producing codebook
library(knitr)
knit2html("codebook.md")

