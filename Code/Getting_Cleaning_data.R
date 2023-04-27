# 0. Libraries
library(tidyverse)

# 1. Get and clean data 
episodes <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-01-24/episodes.csv')
survivalists <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-01-24/survivalists.csv')

## 1.1 Summarize median viewers by for the previous season
    all_seasons <- episodes %>% 
        mutate(season = season+1) %>% # Make the season data match the next season's survivalists
        group_by(season) %>%
        summarise(Median_viewers = median(viewers, na.rm = TRUE)) %>% 
        filter(!is.na(Median_viewers)) %>% 
        ungroup()
    
    
    distinct_df <- distinct(survivalists %>% filter(season == 4), 
                            team, 
                            .keep_all = TRUE)
     
## 1.2 Scale data
    scaled_data <- scale(all_seasons[,2]) 
    
## 1.3 Find Clusters for viewers
    set.seed(1254)
    k_clusters <- 2
    kmeans_result <- kmeans(x = scaled_data, 
                            algorithm = "Hartigan-Wong",
                            centers = k_clusters, 
                            nstart = 1000
                            )
    
    
    all_seasons$cluster <- as.factor(kmeans_result$cluster) # To indicate what data is for each cluster
    
    
    all_seasons %>%
        mutate(Cluster = fct_recode(cluster, 
                                    "1 = High Viewership" = "1", 
                                    "2 = Low Viewership"  = "2"
                                    )
               ) %>%
        ggplot(aes(x = Median_viewers, 
                   y = "1", 
                   color = Cluster
                   )
               ) +
        geom_point() + 
        geom_label(aes(label = season), 
                   size = 5
                   ) + 
        scale_color_manual(values = c("#E7B800", 
                                      "#2E9FDF"
                                      )
                           ) +
        theme(panel.background = element_blank(),
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              axis.title.y = element_blank()
              ) # Visualize clusters
      
## 1.4 Joining season and survivalists data
    clean_data <- survivalists %>% 
      filter(season != 4) %>% 
      rbind(distinct_df) %>%
        select(season, 
               days_lasted, 
               reason_category
               ) %>%
        mutate(status = ifelse(is.na(reason_category), 
                               0, 
                               1
                               ), 
               .keep = "unused"
               )  %>%
        inner_join(all_seasons, 
                   by = "season"
                   )

# 3. Export data
if (!file.exists("Results")) {
  # Create a new directory if it doesn't exist
  dir.create("Results")
  cat("Directory created successfully.\n")
} else {
  cat("Directory already exists.\n")
} # Verify the existence of the directory

save(clean_data, 
     file = 'Results/Results.Rdata'
     ) # To save as Rdata
    
