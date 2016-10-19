########################################################################
# Process data
########################################################################
# Author: 
# Ian Hussey (ian.hussey@ugent.be)

# Version:
# 1.0

# Notes:
# prolific_ID is used only to pay participants and must be deleted from all data files before 
# raw data is posted online

# To do:
# None.

########################################################################
# Clean workspace
rm(list=ls())

########################################################################
# Dependencies

library(plyr)
library(dplyr)
library(tidyr)
library(data.table)

########################################################################
# Data acquisition and cleaning

## Set the working directory
setwd("~/git/MatchToSample2x3inquisit/Measures code")

# Read all files with the .iqdat extension
files <- list.files(pattern = "\\.csv$")  

# Read these files sequentially into a single data frame
input_df <- dplyr::tbl_df(plyr::rbind.fill(lapply(files, data.table::fread, header = TRUE)))  # tbl_df() requires dplyr, rbind.fill() requires plyr, fread requires data.table

# Make some variable names more transparent
cleaned_df <- 
  input_df %>%
  dplyr::select(subject,
                date,
                time,
                blockcode,  # name of block
                blocknum,
                trialnum,
                response,  # for string responses
                correct,
                latency) %>%
  dplyr::rename(participant = subject,
                block_name = blockcode,
                block_n = blocknum,
                trial_n = trialnum,
                string_response = response,
                accuracy = correct,
                rt = latency) %>%
  dplyr::mutate(participant = as.numeric(participant),
                block_n = as.numeric(block_n),
                trial_n = as.numeric(trial_n),
                accuracy = as.numeric(accuracy),
                rt = as.numeric(rt),
                condition = ifelse(participant%%2 == 1, 1, ifelse(participant%%2 == 0, 2, NA)))
  
  # MANUAL EXCLUSIONS HERE (TEST PARTICIPANTS, DUPLICATES, ETC)
  #dplyr::filter(participant != 1)


########################################################################
# demographics and parameters 

demographics_df <-
  cleaned_df %>%
  dplyr::group_by(participant) %>%
  dplyr::filter(grepl("demographics", block_name)) %>%  # filter rows where the block_name includes string
  dplyr::select(participant, condition, trial_n, string_response) %>%  # select only necessary columns
  tidyr::spread(trial_n, string_response) %>%  # convert rows to columns
  dplyr::rename(age = `1`,  # rename for clarity
                gender = `2`,
                prolific_ID = `3`) %>% # NB this must be removed from both summary and raw files before data is posted online
  dplyr::select(-prolific_ID)

########################################################################
# relational training

# select relevant data
rel_train_df <-
  cleaned_df %>%
  dplyr::filter(grepl("Relational_Training_Phase", block_name)) %>%  # filter rows where the block_name includes string
  dplyr::select(participant, accuracy, block_n)

# n blocks
rel_train_n_blocks_df <-
  rel_train_df %>%
  dplyr::group_by(participant) %>%
  dplyr::summarize(rel_train_n_blocks = max(block_n, na.rm = TRUE))

# % accuracy on last block and pass/fail mastery criterion
rel_train_perc_acc_df <-
  rel_train_df %>%
  dplyr::group_by(participant) %>%
  dplyr::filter(block_n == max(block_n, na.rm = TRUE)) %>%  # filter only the last of their blocks (up to 5)
  dplyr::summarize(rel_train_perc_acc = round(sum(accuracy)/n(), 3)*100) %>%
  dplyr::mutate(rel_train_mastery = ifelse(rel_train_perc_acc >= 87.5, "pass", "fail"))  # 87.5 is 14/16 correct


########################################################################
# relational testing

# select relevant data, % accuracy and pass/fail mastery criterion
rel_test_perc_acc_df <-
  cleaned_df %>%
  dplyr::filter(grepl("Relational_Testing_Phase", block_name)) %>%  # filter rows where the block_name includes string
  dplyr::select(participant, accuracy) %>%
  dplyr::group_by(participant) %>%
  dplyr::summarize(rel_test_perc_acc = round(sum(accuracy)/n(), 3)*100) %>%  # % accuracy
  dplyr::mutate(rel_test_mastery = ifelse(rel_test_perc_acc >= 87.5, "pass", "fail"))  # 87.5 is 14/16 correct


# examine pattern of accuracy:
testing_by_trial <-
  cleaned_df %>%
  filter(block_name == "Relational_Testing_Phase_BC") %>%
  select(participant, accuracy, trial_n) %>%
  spread(trial_n, accuracy)

# pattern of accuracy on rel test
#testing_by_trial <-
#  join(rel_test_perc_acc_df, testing_by_trial, by = "participant")
#View(testing_by_trial)

# pattern of accuracy on rel test in participants who pass
#testing_by_trial %>% filter(rel_test_mastery == "pass") %>% View()
#write.csv(testing_by_trial, "relational testing by trial.csv", row.names = FALSE)
## suggests people who derive do it from the very first trial


########################################################################
# Join data frames and assess exclusion criteria

# join dfs
output_df <- 
  plyr::join_all(list(as.data.frame(demographics_df),  # join_all throws a requires input be data.frame error, despite is.data.frame returning TRUE for all members of list. Workaround is to coerce all to DF here. 
                      as.data.frame(rel_train_n_blocks_df),
                      as.data.frame(rel_train_perc_acc_df),
                      as.data.frame(rel_test_perc_acc_df)),
                 by = "participant",
                 type = "full")

# define IAT outliers (+/- 2.5 SD on lat or acc)
IAT_outlier_cutoffs_df <- 
  output_df %>% 
  dplyr::summarize(accuracy_upper = mean(IAT_test_perc_acc, na.rm = TRUE) + (2.5 * sd(IAT_test_perc_acc, na.rm = TRUE)),
                   accuracy_lower = mean(IAT_test_perc_acc, na.rm = TRUE) - (2.5 * sd(IAT_test_perc_acc, na.rm = TRUE)),
                   latency_upper = mean(IAT_test_rt_mean, na.rm = TRUE) + (2.5 * sd(IAT_test_rt_mean, na.rm = TRUE)),
                   latency_lower = mean(IAT_test_rt_mean, na.rm = TRUE) - (2.5 * sd(IAT_test_rt_mean, na.rm = TRUE)))

# define IAT outliers (add to output_df)
output_df <- 
  output_df %>%
  dplyr::mutate(IAT_outlier = ifelse(IAT_test_perc_acc > IAT_outlier_cutoffs_df$accuracy_upper, TRUE, 
                                     ifelse(IAT_test_perc_acc < IAT_outlier_cutoffs_df$accuracy_lower, TRUE,
                                            ifelse(IAT_test_rt_mean > IAT_outlier_cutoffs_df$latency_upper, TRUE,
                                                   ifelse(IAT_test_rt_mean < IAT_outlier_cutoffs_df$latency_lower, TRUE, FALSE)))))

# Assess if each participant meet the training criterion, or is an outlier on the IAT, mark for exclusion. 
# This also excludes participants with partial data.
# NB performance on the relational test (i.e., equivalence test) is not included here as it is an IV for some analyses.
output_df <- 
  output_df %>%
  rowwise() %>%
  dplyr::mutate(exclude = ifelse(rel_train_mastery == "fail", TRUE, 
                                 ifelse(IAT_test_exclude_based_on_fast_trials == "fail", TRUE,
                                        ifelse(IAT_outlier == TRUE, TRUE,
                                               FALSE))))


########################################################################
# Write to disk
write.csv(output_df, file = "~/git/MatchToSample2x3inquisit/Data processing code/processed data for analysis.csv", row.names = FALSE)

