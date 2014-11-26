import sys
import re
import csv

def deverticalize(verticalFile, keyColumnName, horizontalFile):
    
    ifile = open(verticalFile, "rb")
    reader = csv.reader(ifile)

    header = {}
    rownum = 0
    deverticalizedData = {} # a map from keyColumn to a list!
    for row in reader:
    # Save header row.
        if rownum == 0:
            for col in row:
                header[col] = len(header)
            if not header.has_key(keyColumnName):
                print >>sys.stderr, 'ERROR: the given column does not appear in the header (%s)'  % (keyColumnName)
                sys.exit()
            else:
                keyColumnNo = header[keyColumnName]
        else:
            keyValue = row[keyColumnNo]
            if not deverticalizedData.has_key(keyValue):
                deverticalizedData[keyValue] = [keyValue]
            
            for i in range(len(row)):
                if i != keyColumnNo:
                    deverticalizedData[keyValue].append(row[i])
                
        rownum += 1
    ifile.close()
    
    ofile = open(horizontalFile, "w")
    for key in deverticalizedData.keys():
        print >>ofile, ','.join(deverticalizedData[key])

    ofile.close()

if __name__ == "__main__":
    argv = sys.argv
    if len(argv) != 4:
        raise Exception('Usage: '+argv[0]+' vertical_inputCSV primaryKeyName horizontal_outputCSV');
    vertical_inputCSV = argv[1]
    primaryKeyName = argv[2]
    horizontal_outputCSV = argv[3]
    deverticalize(sys.argv[1], primaryKeyName, horizontal_outputCSV)
    print 'Done!'
    sys.exit()
    




