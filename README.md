# Covid-19 Illinois

This repository is an R script designed to plot Illinois-specific graphs of the
Covid-19 epidemic within the state. It uses county-level data [released by the
New York Times](https://github.com/nytimes/covid-19-data). These data are split
up according to the following particular regions of Illinois: Cook county
(which includes the city of Chicago), the collar counties (i.e., DuPage, Kane,
Lake, McHenry, and Will counties), and outside the Chicago metro area (i.e.,
outside of Cook and collar counties). The reason for dividing into these three
areas was to look at how Covid-19 cases are trending across three roughly
equal areas by population. That is, there are about 4 million people in each
of these three areas.

The population of Cook county, the collar counties, and the entire state of
Illinois are taken from each county's and the state's Wikipedia pages.

## Usage

Running this R script will download the raw county-level data from the New York
Times' GitHub page, extract the Illinois-specific data, and then generate the
following plots based on these data. The raw CSV file and generated PNG images
will be saved within the working directory of the script.

* Number of Covid-19 cases by region
* Cases per capita by region
* Number of cases by region on a logarthmic scale
* Number of deaths by region
* Mortality rate (deaths/cases) by region

## Notes

While the data begins at January 21, 2020, this script filters the data to
begin on March 1, 2020, since the first Covid-19 case in Illinois did not occur
until March. Similarly, the x-axis of the mortality rate plot begins on March
15, 2020 because the first death in Illinois related to Covid-19 did not occur
until later in March.

## Contribute

Feel free to report any [issues](/issues) or to make [pull requests](/pulls).

