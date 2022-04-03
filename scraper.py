#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from cgitb import text
from bs4 import BeautifulSoup
import requests
import numpy
import csv


class JFWebScraper():
    def __init__(self, url):
        """Class that is used to extract headlines, subheadlines and text from Junge Freiheit articles from an URL.
        Args:
            url (str): URL in string format 
        Returns:
            None
        """
        self.url = url
        self.headline = ''
        self.subheadlines = ''
        self.paragraphs = ''

    def _write_file(self, filename):
        """Function that writes a csv file containing relevant data.
        Args:
            filename (str): name of the csv file 
        Returns:
            None
        """
        with open(filename, mode="w", encoding="utf-8", newline="\n") as results_file:
            results_writer = csv.writer(results_file, delimiter=";",
                                        quotechar='"',
                                        quoting=csv.QUOTE_MINIMAL)
            results_writer.writerow(['HEAD', 'SUBHEAD', 'TEXT'])
            # first row for column names
            results_writer.writerow(
                [self.headline, self.subheadlines, self.paragraphs])
                # following rows: data

    def scrape(self):
        """Function that scrapes data from a Junge Freiheit article URL.
        Args:
            None
        Returns:
            None
        """
        r1 = requests.get(self.url)
        coverpage = r1.content
        soup1 = BeautifulSoup(coverpage, 'lxml')
        # set up BeautifulSoup object
        coverpage_news = soup1.find_all(
            'h2', class_="elementor-heading-title elementor-size-default")
        self.headline = coverpage_news[0].get_text()
        text_news = soup1.find_all(
            'div', class_="elementor-element elementor-element-28485dd1 elementor-widget elementor-widget-theme-post-content")
        pagraphs = text_news[0].find_all('p')
        # extract relevant data (headlines, subheadlines, paragraphs)
        list_paragraphs = []
        for p in numpy.arange(0, len(pagraphs)):
            paragraph = pagraphs[p].get_text()
            list_paragraphs.append(paragraph.rstrip())
        self.paragraphs = ' '.join(list_paragraphs)
        # extract separate paragraphs from html and join together into one big string
        subheads = text_news[0].find_all('h3')
        for subhead in subheads:
            self.subheadlines += subhead.get_text()+' '
            # separate subheadlines with dot


class TSWebScraper():
    def __init__(self, url):
        """Class that is used to extract headlines, subheadlines and text from Tagesschau articles from an URL.
        Args:
            url (str): URL in string format 
        Returns:
            None
        """
        self.url = url
        self.headline = ''
        self.subheadlines = ''
        self.paragraphs = ''

    def _write_file(self, filename):
        """Function that writes a csv file containing relevant data.
        Args:
            filename (str): name of the csv file 
        Returns:
            None
        """
        with open(filename, mode="w", encoding="utf-8", newline="\n") as results_file:
            results_writer = csv.writer(results_file, delimiter=";",
                                        quotechar='"',
                                        quoting=csv.QUOTE_MINIMAL)
            results_writer.writerow(['HEAD', 'SUBHEAD', 'TEXT'])
            results_writer.writerow(
                [self.headline, self.subheadlines, self.paragraphs])

    def scrape(self):
        """Function that scrapes data from a Tagesschau article URL.
        Args:
            None
        Returns:
            None
        """
        r1 = requests.get(self.url)
        coverpage = r1.content
        soup1 = BeautifulSoup(coverpage, 'lxml')
        # get headline
        coverpage_news = soup1.find_all(
            'span', class_="seitenkopf__headline--text")
        self.headline = coverpage_news[0].get_text()
        # get text
        text_news = soup1.find_all('article', class_="container")
        pagraphs = text_news[0].find_all('p')
        list_paragraphs = []
        for p in numpy.arange(0, len(pagraphs)):
            paragraph = pagraphs[p].get_text()
            list_paragraphs.append(paragraph.rstrip())
        self.paragraphs = ' '.join(list_paragraphs)
        # get subheadlines
        subheads = text_news[0].find_all('h2')
        for subhead in subheads:
            self.subheadlines += subhead.get_text()+' '


if __name__ == "__main__":
    f = open('jf-urls.txt', 'r')
    counter = 0
    print("collecting JF data...")
    for line in f:
        if line != '':
            wscrape = JFWebScraper(line)
            wscrape.scrape()
            wscrape._write_file(f'jf-{counter}.csv')
            print(f'article {counter} scraped')
            counter += 1

    t = open('ts-urls.txt', 'r')
    print("collecting TS data...")
    counter = 0
    for line in t:
        if line != '':
            tscrape = TSWebScraper(line)
            tscrape.scrape()
            tscrape._write_file(f'ts-{counter}.csv')
            print(f'article {counter} scraped')
            counter += 1
