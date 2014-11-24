#!/usr/bin/env python
import csv
import os
import sys
from xml.dom import minidom

def updateDetails(username, dataFile, primaryCol_name, urlCol_name, labelCol_name, haveLabels, questionFile):
    text_to_selid = {}
    pathToFiles = "users/" + username + "/files/";
    doc = minidom.parse(pathToFiles + questionFile)
    selections = doc.getElementsByTagName("Selection")
    for selection in selections:
        identifier = selection.getElementsByTagName("SelectionIdentifier")[0]
        text = selection.getElementsByTagName("Text")[0]
        text_to_selid[text.firstChild.data] = identifier.firstChild.data

    with open(pathToFiles + dataFile, 'rb') as readFile_obj:
        # rename details file
        base = os.path.splitext(dataFile)[0]
        dataFile_updated = base + ".updatedDetails"
        with open(pathToFiles + dataFile_updated, 'w+') as writeFile_obj:
            writer = csv.writer(writeFile_obj)
            reader = csv.reader(readFile_obj)
            readFirstLine = False
            for row in reader:
                row = [word.strip() for word in row] 
                if not readFirstLine:
                    # parse first line
                    # map col names to indices
                    i = 0
                    for col_name in row:
                        if col_name == primaryCol_name:
                            primaryCol_index = i
                        elif col_name == urlCol_name:
                            urlCol_index = i
                        elif col_name == labelCol_name:
                            labelCol_index = i
                        i = i+1
                    readFirstLine = True
                else:
                    # parse every other line
                    # write data to updated details file
                    if haveLabels == 'true':
                        text = row[labelCol_index]
                        selid = text_to_selid[text]
                        writer.writerow([row[primaryCol_index], row[urlCol_index], selid])
                    else:
                        writer.writerow([row[primaryCol_index], row[urlCol_index], "-1"])

if __name__ == "__main__":
    # updateDetails("sam", "face10.details", "PrimaryKey", "publishedURL", "orientation", "face10.question")
    updateDetails(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7])
