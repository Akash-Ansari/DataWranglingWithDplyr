#
# Copyright 2017 Dave Langer
#    
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 



#
# This R source code file corresponds to video 1 of the YouTube series
# "Data Wrangling & Feature Engineering with dplyr" located at the following URL:
#     https://youtu.be/fuB7s19g3nQ     
#




#======================================================================
# Create summary stats for Fare
#
library(dplyr)
library(stringr)

train <- read.csv("titanic_train.csv", stringsAsFactors = FALSE)



#======================================================================
# Create summary stats for Fare
#
fare.stats <- train %>%
  summarize(Fare.Min = min(Fare),
            Fare.Max = max(Fare),
            Fare.Mean = mean(Fare),
            Fare.Median = median(Fare),
            Fare.Var = var(Fare),
            Fare.SD = sd(Fare),
            Fare.IQR = IQR(Fare))
fare.stats



#======================================================================
# Add the new feature for the Title of each passenger
#
train <- train %>%
  mutate(Title = str_extract(Name, "[a-zA-Z]+\\."))

table(train$Title)



#======================================================================
# Condense titles down to small subset
#
mister.titles <- c("Capt.", "Col.", "Don.", "Dr.",
                   "Jonkheer.", "Major.", "Rev.", "Sir.")
train$Title[train$Title %in% mister.titles] <- "Mr."

mrs.titles <- c("Dona.", "Lady.", "Mme.", "Countess.")
train$Title[train$Title %in% mrs.titles] <- "Mrs."

miss.titles <- c("Mlle.", "Ms.")
train$Title[train$Title %in% miss.titles] <- "Miss."

table(train$Title)



#======================================================================
# Double-check our work
#
train %>%
  filter((Sex == "female" & (Title == "Mr." | Title == "Master.")) |
         (Sex == "male" & (Title == "Mrs." | Title == "Miss.")))

train$Title[train$PassengerId == 797] <- "Mrs."



#======================================================================
# Impute ages using the median
#
age.lookup <- train %>%
  group_by(Pclass, Title) %>%
  summarize(Age.Median = median(Age, na.rm = TRUE))
age.lookup



#======================================================================
# Update missing ages using lookup table
#
train <- train %>%
  left_join(age.lookup, by = c("Pclass", "Title")) %>%
  mutate(Age = ifelse(is.na(Age), Age.Median, Age)) %>%
  select(-Age.Median)



#======================================================================
# Create Ticket-based features
#
ticket.lookup <- train %>%
  group_by(Ticket) %>%
  summarize(Group.Count = n(),
            Avg.Fare = sum(Fare) / n(),
            Female.Count = length(which(Sex == "female")),
            Male.Count = length(which(Sex == "male")),
            Child.Count = length(which(Age < 16)),
            Female.Ratio = length(which(Sex == "female")) / n(),
            Male.Ratio = length(which(Sex == "male")) / n(),
            Child.Ratio = length(which(Age < 16)) / n())
View(ticket.lookup)



#======================================================================
# Populate training data via lookup table
#
train <- train %>%
  left_join(ticket.lookup, by = "Ticket")
View(train)


