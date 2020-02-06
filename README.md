# Credit_Scoring
## Collecting data
Our data are collected from two sources: customers’ data in our databases and data from the third party.

As of the first part, when a customer applies for a loan, he or she needs to fill in a form, which includes the customer’s name, address, cell phone number, gender, loan’s uses, etc. We collect these data and can retrieve them by using SQL. 

The second part of the data is the customer’s credit history and credit report from other credit agencies. Data fields include customers’ names, identification number, loan amount, loan date, loan period, repay date, if the loan is repaid, borrower, etc. We also collect customers’ call records and cellular data records.

I retrieve the raw data from databases, convert them into the same format and do the data cleaning.

## Feature engineering
To add more dimensions to our model, I do the feature engineering job and generate about a thousand features from the original data. I mainly use Pandas package in this step. For example, to count a customer’s total overdue loan amount in the past three months, I select the customer’s last three months’ loan records which are not repaid, group by customer’s identification number, and sum them. Other features include customers’ credit records that are grouped by the repay state, overdue state, and do min/ max/ average/ sum over 1/3/6/12 months. Also, I count their phone call records by morning/evening, etc.

## Feature selection
Too many features will destroy the model since I do not have enough data. So I need to reduce the features. I use the following three methods: lambda one regularization, random forest’s feature importance and spearsman correlation score.

## Model selection
I choose four models to fit the model: random forest, logistic regression, XgBoost, LightGbm
Fit the model. By using 5 fold cross-validation, I find that the XgBoost model performs best. So finally I use XgBoost to fit the model. To tune the models’ hyperparameters, I use a random search and grid view search to decide the final value.

## Evaluate the model
I use to use the KS value to evaluate the model.

## Monitor
