import csv
import os
from xml.dom import minidom

# import updateDetails
# updateDetails.updateDetails("face10.details", "PrimaryKey", "PublishedURL", "orientation", "face10.question")

def updateDetails(dataFile, primaryCol_name, urlCol_name, labelCol_name, questionFile):
    text_to_selid = {}
    doc = minidom.parse("../uploads/" + questionFile)
    selections = doc.getElementsByTagName("Selection")
    for selection in selections:
        identifier = selection.getElementsByTagName("SelectionIdentifier")[0]
        text = selection.getElementsByTagName("Text")[0]
        text_to_selid[text.firstChild.data] = identifier.firstChild.data

    with open("../uploads/" + dataFile, 'rb') as readFile_obj:
        # rename details file
        base = os.path.splitext(dataFile)[0]
        dataFile_updated = base + ".updatedDetails"
        with open("../uploads/" + dataFile_updated, 'w+') as writeFile_obj:
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
                    text = row[labelCol_index]
                    selid = text_to_selid[text]
                    writer.writerow([row[primaryCol_index], row[urlCol_index], selid])

