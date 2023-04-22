# Libraries
library(survminer)
library(survival)

# Verify assumptions
## Fit a survival object for the log-rank test
surv.obj <- Surv(clean_data$days_lasted, 
                 clean_data$status)

## Check the proportional hazards assumption
cox.ph <- coxph(surv.obj ~ cluster, 
                data = clean_data)
summary(cox.ph)

## Check the assumption of non-informative censoring
cox.zph <- cox.zph(cox.ph)
ggcoxzph(cox.zph)
print(cox.zph)

## Run the log-rank test
surv.test <- survdiff(surv.obj ~ cluster, 
                      data = clean_data)
print(surv.test)

## Survival analysis

surv_object <- survfit(Surv(days_lasted, status)~cluster, 
                       data = clean_data)

# Run analysis
ggsurvplot(
    fit = surv_object,
    data = clean_data,
    size = 1,                 # change line size
    palette = c("#E7B800", 
                "#2E9FDF"
                ), # custom color palettes
    conf.int = TRUE,           # Add confidence interval
    pval = TRUE,               # Add p-value
    risk.table = TRUE,         # Add risk table
    risk.table.col = "strata", # Risk table color by groups
    legend.labs = c("High Viewership", 
                    "Low Viewership"
                    ),    # Change legend labels
    risk.table.height = 0.25, # Useful to change when you have multiple groups
    ggtheme = theme(panel.background = element_blank())      # Change ggplot2 theme
    )  +
labs(fill = "Previous Season Viewership",
     color = "Previous Season Viewership")  # Change legend title

