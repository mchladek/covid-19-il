require(readr)
require(dplyr)
require(ggplot2)

# load data
counties <-
  read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv",
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

# get first day 100 cases reached for each region
il_counties %>%
  group_by(date, Region) %>%
  summarise(count = sum(cases)) %>%
  filter(count >= 100, Region == "Cook County") %>%
  arrange(date) %>%
  .[[1, 1]] %>%
  c("Cook County" = .) -> first100

il_counties %>%
  group_by(date, Region) %>%
  summarise(count = sum(cases)) %>%
  filter(count >= 100, Region == "Collar Counties") %>%
  arrange(date) %>%
  .[[1, 1]] -> first100Collar

first100 <- append(first100, c("Collar Counties" = first100Collar))

il_counties %>%
  group_by(date, Region) %>%
  summarise(count = sum(cases)) %>%
  filter(count >= 100, Region == "Outside Chi Metro") %>%
  arrange(date) %>%
  .[[1, 1]] -> first100Out

first100 <- append(first100, c("Outside Chi Metro" = first100Out))

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

# generate plot of cases per 100k residents by region
casesPerCap <- il_counties %>%
  filter(date >= march) %>%
  group_by(date, Region) %>%
  summarise(count = sum(cases)) %>%
  mutate(countPerCap = (count * 100000) / pops[Region]) %>%
  ggplot(aes(x = date, y = countPerCap)) +
  geom_line(aes(color = Region)) +
  geom_point(aes(color = Region), size = 1) +
  labs(x = "Date", y = "Number of Cases Per 100k Residents",
       title = "Number of Covid-19 Cases Per 100k Residents in Illinois by Region",
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
  mutate(daysFrom100 = as.numeric(date - first100[Region])) %>%
  filter(daysFrom100 >= 0) %>%
  ggplot(aes(x = daysFrom100, y = count)) +
  geom_line(aes(color = Region)) +
  geom_point(aes(color = Region), size = 1) +
  stat_function(fun = function(.x) (2^(.x)*100), inherit.aes = F,
                color = "grey") +
  annotate("text", x=5, y=8000, label="Doubles every day", color = "grey") +
  stat_function(fun = function(.x) (2^(.x/2)*100), inherit.aes = F,
                color = "grey") +
  annotate("text", x=11, y=8000, label="...every 2 days", color = "grey") +
  stat_function(fun = function(.x) (2^(.x/3)*100), inherit.aes = F,
                color = "grey") +
  annotate("text", x=18, y=8000, label="...every 3 days", color = "grey") +
  stat_function(fun = function(.x) (2^(.x/7)*100), inherit.aes = F,
                color = "grey") +
  annotate("text", x=18, y=800, label="...every week", color = "grey") +
  stat_function(fun = function(.x) (2^(.x/30)*100), inherit.aes = F,
                color = "grey") +
  annotate("text", x=19, y=200, label="...every month", color = "grey") +
  scale_y_continuous(trans = "log10", limits = c(100, 10000)) +
  scale_x_continuous(limits = c(0, 20)) +
  labs(x = "Days Since 100th Case", y = "Number of Cases",
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
