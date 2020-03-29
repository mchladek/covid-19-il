require(readr)
require(curl)
require(dplyr)
require(ggplot2)

# load data
counties <-
  read_csv(curl("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv"),
           col_types = cols(date = col_date(format = "%Y-%m-%d")))

# exact Illinois-specific data and fill region
il_counties <- subset(counties, state == "Illinois")

il_counties$Region <- NA
il_counties$Region[il_counties$county == "Cook"] <- "Cook County"
il_counties$Region[il_counties$county %in% c("Dupage", "DuPage", "Will", "Lake",
                                             "McHenry", "Mchenry",
                                             "Kane")] <- "Collar Counties"
il_counties$Region[is.na(il_counties$Region)] <- "Outside Chi Metro"

il_counties$Region <- factor(il_counties$Region, levels = c("Cook County",
                                                            "Collar Counties",
                                                            "Outside Chi Metro"))

# set start date and region populations
march <- as.Date("03/01/2020", "%m/%d/%Y")
pops <- c("Cook County" = 5194675,
          "Collar Counties" = 916924 + 677560 + 703462 + 308760 + 515269,
          "Outside Chi Metro" = (12671821 - (5194675 + 916924 + 677560 + 703462 + 308760 + 515269)))

# generate plot of overall cases by region
cases <- il_counties %>%
  filter(date >= march) %>%
  group_by(date, Region) %>%
  summarise(count = sum(cases)) %>%
  ggplot(aes(x = date, y = count)) +
  geom_line(aes(color = Region)) +
  geom_point(aes(color = Region), size = 1) +
  labs(x = "Date", y = "Number of Cases",
       title = "Total Number of Covid-19 Cases in Illinois by Region",
       caption = "Data from The New York Times, based on reports from state and local health agencies") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 9),
        legend.position = "bottom")
png(filename = "cases.png", width = 800, height = 675)
plot(cases)
dev.off()

# generate plot of cases per capita by region
casesPerCap <- il_counties %>%
  filter(date >= march) %>%
  group_by(date, Region) %>%
  summarise(count = sum(cases)) %>%
  mutate(countPerCap = count/pops[Region]) %>%
  ggplot(aes(x = date, y = countPerCap)) +
  geom_line(aes(color = Region)) +
  geom_point(aes(color = Region), size = 1) +
  labs(x = "Date", y = "Number of Cases Per Capita",
       title = "Number of Covid-19 Cases Per Capita in Illinois by Region",
       caption = "Data from The New York Times, based on reports from state and local health agencies") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 9),
        legend.position = "bottom")
png(filename = "casesPerCap.png", width = 800, height = 675)
plot(casesPerCap)
dev.off()

# generate plot of overall cases by region on logarthmic scale
casesLog <- il_counties %>%
  filter(date >= march) %>%
  group_by(date, Region) %>%
  summarise(count = sum(cases)) %>%
  ggplot(aes(x = date, y = count)) +
  geom_line(aes(color = Region)) +
  geom_point(aes(color = Region), size = 1) +
  scale_y_continuous(trans = "log10") +
  labs(x = "Date", y = "Number of Cases (log)",
       title = "Total Number of Covid-19 Cases in Illinois by Region (Log Scale)",
       caption = "Data from The New York Times, based on reports from state and local health agencies") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 9),
        legend.position = "bottom")
png(filename = "casesLog.png", width = 800, height = 675)
plot(casesLog)
dev.off()

# generate plot of overall deaths by region
deaths <- il_counties %>%
  filter(date >= march) %>%
  group_by(date, Region) %>%
  summarise(count = sum(deaths)) %>%
  ggplot(aes(x = date, y = count)) +
  geom_line(aes(color = Region)) +
  geom_point(aes(color = Region), size = 1) +
  labs(x = "Date", y = "Number of Deaths",
       title = "Total Number of Covid-19 Related Deaths in Illinois by Region",
       caption = "Data from The New York Times, based on reports from state and local health agencies") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 9),
        legend.position = "bottom")
png(filename = "deaths.png", width = 800, height = 675)
plot(deaths)
dev.off()

# generate plot of mortality rate by region
mortality <- il_counties %>%
  filter(date >= as.Date("03/15/2020", "%m/%d/%Y")) %>%
  group_by(date, Region) %>%
  summarise(mortC = sum(cases), mortD = sum(deaths)) %>%
  mutate(mort = mortD/mortC) %>%
  ggplot(aes(x = date, y = mort)) +
  geom_line(aes(color = Region), alpha = 0.5) +
  stat_smooth(aes(color = Region), method = "loess", se = F) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(x = "Date", y = "Mortality Rate (%)",
       title = "Mortality Rate (Deaths/Cases) of Covid-19 in Illinois by Region",
       caption = "Data from The New York Times, based on reports from state and local health agencies") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 9),
        legend.position = "bottom")
png(filename = "mortality.png", width = 800, height = 675)
plot(mortality)
dev.off()
