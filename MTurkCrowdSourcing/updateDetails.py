# to run this code:
# import updateDetails
# updateDetails.updateDetails("face10.details", "PrimaryKey", "PublishedURL", "orientation", "face10.question")
import csv
import os
import xml.etree.ElementTree as ET

def updateDetails(dataFile, primaryCol_name, urlCol_name, labelCol_name, questionFile):
    tree = ET.parse("../uploads/" + questionFile)
    root = tree.getroot()
    for elem in root.findall(".//Selection"): 
        identifier = elem.find("SelectionIdentifier").text
        text = elem.find("Text").text
        print identifier, text

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
                    writer.writerow([row[primaryCol_index], row[urlCol_index], row[labelCol_index]])

