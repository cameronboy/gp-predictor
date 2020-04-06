import requests as r
import pandas as pd 
import ast
import pprint as p
import numpy as np
import time


pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 1000)

# YEAR/ROUND/CLASS/SESSION
BASE_URL = 'http://www.motogp.com'
RESULTS_URL = 'http://www.motogp.com/en/ajax/results/parse/'
SELECTOR_URL = 'http://www.motogp.com/en/ajax/results/selector/'

def clean_url(url):
    url = url.replace('\\','')
    return BASE_URL + url

dat = pd.DataFrame()

for year in range(2012, 2020):
    print(year)
    url = SELECTOR_URL + str(year)
    events_request = r.get(url).text
    events_dict = ast.literal_eval(events_request)

    for i, event in enumerate(events_dict.values()):
        event_number = i
        class_url = clean_url(event['url'])
        event_name = event['shortname']
        event_title = event['title']
        class_request = r.get(class_url).text
        class_list = ast.literal_eval(class_request)

        for cls in class_list:
            cls_url = clean_url(cls['url'])
            class_name = cls['name']
            cls_request = r.get(cls_url).text
            cls_list = ast.literal_eval(cls_request)

            for session in cls_list:
                session_url = clean_url(session['url'])
                session_url = session_url.replace('selector','parse')
                print(session_url)
                try:
                    res = pd.read_html(session_url, flavor='html5lib')[0]
                except ValueError:
                    continue
                res['class'] = class_name
                res['year'] = year
                res['event'] = event_name
                res['title'] = event_title
                res['session'] = session['name']
                res['event_number'] = event_number
                dat = dat.append(res, ignore_index=True)
                dat.head(1)


        
