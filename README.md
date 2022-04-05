This project was written on Fedora Linux 35 with Python 3.7.6. (scraper) and R 4.1.2 (score calculation)

## INTRODUCTION
The following project is a combination of a newspaper scraper (made with beautifulsoup) that extracts headlines, subheadlines and text of articles published by Junge Freiheit and Tagesschau. 

## DESCRIPTION
The R script 'polscore.r' uses a precompiled corpus of 50 Junge Freiheit articles and 50 Tagesschau articles, their headlines, subheadlines and text are saved in .csv files. 
If desired, the corpus can be recompiled or changed/expanded by removing or adding article URLs to jf-urls.txt and ts-urls.txt and running the scraper.
When running the R script, a 'polarity score' is calculated for each category. For this, SentiWS is used to distingiush which words are negatively or positively polarized. The occurrences of exclamation and question marks are also taken into account.
For more information, read the 'report.csv'.
 
## REQUIREMENTS
Python 3.7.6 with the following modules:
text, BeautifulSoup, numpy, csv
R 4.1.2 with the following modules:
quanteda, readtext, tidyverse, tm

## HOW TO USE
1. (Optional): If you want to use your own links or expand on the corpus, simply modify ts-urls.txt and jf-urls.txt, delete the corpus folder, and use the following command:
`python scraper.py`. The new .csv-files will appear in the root directory of the project. It is, however, recommended to use the given corpus.
2. Open RStudio and run 'polscore.r'. The results will be saved in 'results.csv' for potential further development. Two graphs presenting the results will be saved in the root directory of the project.

## PROBLEMS/BUGS
As the Junge Freiheit serves seem instable sometimes, a maximum runtime exceeded error might occur during the scraping process. In such cases, run the scraper again or discard the problematic URL.

## Author: 
Lea Wetzke / 797451 / Automatische Textanalyse in den Politikwissenschaften WiSe 2021/22 / [lwetzke@uni-potsdam.de](mailto:lwetzke@uni-potsdam.de)
