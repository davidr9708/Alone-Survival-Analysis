# Libraries
library(tidyverse)

# Get data 
episodes <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-01-24/episodes.csv')
survivalists <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-01-24/survivalists.csv')

# Clean data
## Summarize median viewers by season
all_seasons <- episodes %>% 
    mutate(season = season+1) %>% # Make the season data match the next season's survivalists
    group_by(season) %>%
    summarise(Median_viewers = median(viewers, na.rm = TRUE)) %>% 
    filter(!is.na(Median_viewers)) %>% ungroup()

## Scale data
scaled_data <- scale(all_seasons[,2]) 

## Clustering
k_clusters <- 2
kmeans_result <- kmeans(x = scaled_data, 
                        algorithm = "Hartigan-Wong",
                        centers = k_clusters, 
                        nstart = 1000
                        )

all_seasons$cluster <- as.factor(kmeans_result$cluster) # To indicate what data is for each cluster

### Show the selection of the clusters
all_seasons %>%
  mutate(Cluster = fct_recode(cluster, 
                              "1 = High Viewership" = "1", 
                              "2 = Low Viewership"  = "2"
  )) %>%
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
                       "#2E9FDF"))+
  theme(panel.background = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank()
        )

## Joining season and survivalists data
clean_data <- survivalists %>% 
  select(season, 
         days_lasted, 
         reason_category
         ) %>%
  mutate(status = ifelse(is.na(reason_category), 
                         0, 
                         1
                         ), 
         .keep = "unused"
         ) %>%
  inner_join(all_seasons, by = "season")


