library(caret)
library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(GA)
library(latticeExtra)
library(pROC)
library(doMC)
library(MASS)
library(caTools)

## load data
fulldata <- read.csv("ps_data.csv")
set.seed(123)
## set-up cross-validation
cvIndex <- createMultiFolds(fulldata$CLASS, times = 10)
ctrl <- trainControl(method = "repeatedcv",
                     repeats = 10,
                     classProbs = TRUE,
                     summaryFunction = twoClassSummary,
                     allowParallel = FALSE,
                     index = cvIndex)
ctr <- 1
for (i in 1:100) {
  if(ctr <= 20) {
    ## 'ind' is a vector of 0/1 data denoting which features are being evaluated.
    ind <- sample(0:1,replace = TRUE, size = 30)
    features <- which(ind == 1)
    ## build model using selected features
    modelReduced <- train(fulldata[,features],fulldata$CLASS, method = "qda", metric = "ROC", trControl = ctrl)
    tROC <- caret:::getTrainPerf(modelReduced)[, "TrainROC"]
    if(tROC > 0.7) {
      #print(tROC)
	  print(ctr)
      results <- t(fulldata[0,features])
	  write.csv(results, file = sprintf("rnd%d.csv",ctr))
	  ## make predictions using modelReduced
      prediction <- predict(modelReduced, fulldata[,features], type = "prob")
	  ## generate ROC curve
      curve <- roc(fulldata$CLASS, prediction[,1], levels = rev(levels(fulldata$CLASS)))
	  print(curve)
      ## plot ROC curve and compute AUROC
      rocColors <- c("black", "grey", brewer.pal(8,"Dark2"))
	  jpeg(sprintf("rnd%d.jpg",ctr))
      plot(curve, col = rocColors[1], lwd = 2)
	  dev.off()
	  ctr <- ctr + 1
    }
  }
}




