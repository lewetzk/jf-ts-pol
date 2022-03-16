from cgitb import text
import requests
import numpy
from bs4 import BeautifulSoup  
import csv

url = "https://www.tagesschau.de/wirtschaft/finanzen/rubel-us-dollar-euro-devisen-umtausch-russland-notenbank-101.html"
r1 = requests.get(url)
coverpage = r1.content
soup1 = BeautifulSoup(coverpage, 'lxml')
coverpage_news = soup1.find_all('span', class_ = "seitenkopf__headline--text")
print(coverpage_news[0].get_text())

text_news = soup1.find_all('article', class_ = "container")
x = text_news[0].find_all('p')


subheadlines = text_news[0].find_all('h2')
print(subheadlines)
subhead_list = []
for subhead in subheadlines:
    subhead_list.append(subhead.get_text())
    
print(subhead_list)
 # Unifying the paragraphs
list_paragraphs = []
for p in numpy.arange(0, len(x)):
    paragraph = x[p].get_text()
    list_paragraphs.append(paragraph)
    final_article = " ".join(list_paragraphs)

print(final_article)