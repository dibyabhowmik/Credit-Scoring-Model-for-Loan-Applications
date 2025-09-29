library(dplyr)
library(lattice)
library(ggplot2)
library(caret)
library(pROC)
library(randomForest)

file_path <- "C:/data Analysis project/Credit Scoring Model for Loan Applications/Cleaned_Main_Dataset.csv"
df <- read.csv(file_path)

#Convert loan_status to factor (target variable)
df$loan_status <- as.factor(df$loan_status)

#Train-Test Split
set.seed(123)
trainIndex <- createDataPartition(df$loan_status, p = 0.8, list = FALSE)
train_data <- df[trainIndex, ]
test_data <- df[-trainIndex, ]

#Train Random Forest Model
rf_model <- randomForest(loan_status ~ ., data = train_data, ntree = 100)

##Predict on test set
rf_pred <- predict(rf_model, newdata = test_data)

##Evaluation
conf_matrix <- confusionMatrix(rf_pred, test_data$loan_status)
print(conf_matrix)

##AUC Score
rf_probs <- predict(rf_model, newdata = test_data, type = "prob")[, 2]
auc_score <- roc(test_data$loan_status, rf_probs)
print(paste("AUC:", auc(auc_score)))

##Save the model
saveRDS(rf_model, file = "C:/data Analysis project/Credit Scoring Model for Loan Applications/final_rf_model.rds")

#Add predicted probabilities to full dataset
df$default_prob <- predict(rf_model, newdata = df, type = "prob")[, 2]

#Export to CSV for Power BI
write.csv(df, "C:/data Analysis project/Credit Scoring Model for Loan Applications/Cleaned_Main_Dataset.csv", row.names = FALSE)

##Load the trained model
model <- readRDS("C:/data Analysis project/Credit Scoring Model for Loan Applications/final_rf_model.rds")

##Load the cleaned dataset
df <- read.csv("C:/data Analysis project/Credit Scoring Model for Loan Applications/Cleaned_Main_Dataset.csv")

##Predict default probabilities using the trained model
df$default_prob <- predict(model, newdata = df, type = "prob")[, 2]  # Assuming class "1" is the default class

#Create predicted default flag (optional binary prediction)
df$predicted_default <- ifelse(df$default_prob > 0.5, 1, 0)


# Map loan_status to 0/1
# Adjust the mapping according to your dataset labels
df$loan_status_num <- ifelse(df$loan_status %in% c("Default", "1", 1), 1, 0)

# Ensure predicted_default is numeric
df$pred_default_num <- as.numeric(df$predicted_default)

# Calculate accuracy
accuracy <- mean(df$loan_status_num == df$pred_default_num, na.rm = TRUE)
cat("Model Accuracy:", round(accuracy * 100, 2), "%\n")



##Export the updated dataset with predictions
write.csv(df, "C:/data Analysis project/Credit Scoring Model for Loan Applications/Predictions_with_Scores.csv", row.names = FALSE)

cat("File successfully saved as 'Predictions_with_Scores.csv' in the project folder.\n")
