'''
Created on May 13, 2012

@author: sina
'''

from analysis import save_classifier, words_in_tweet, POSITIVE, NEGATIVE, NEUTRAL
from nltk.metrics.association import BigramAssocMeasures

import collections, itertools
import datetime
import nltk
import nltk.classify.util, nltk.metrics
import os
import pickle
import re
import random
import sys


# lots of stuff from http://streamhacker.com/2010/06/16/text-classification-sentiment-analysis-eliminate-low-information-features/
# and http://nltk.googlecode.com/svn/trunk/doc/book/ch06.html

#smilefile = open('smiley.txt.processed.2009.05.25')
#frownfile = open('frowny.txt.processed.2009.05.25')

def features(feat_func, handle, label):
    print "Generating features for '%s'" % (label)
    print datetime.datetime.now()
    return [((feat_func(words_in_tweet(line))), label) for line in handle]

def update_wordcount(word_fd, label_word_fd, handle, label):
    print "Counting '%s'" % (label)
    print datetime.datetime.now()
    for line in handle:
        for word in words_in_tweet(line):
            word_fd.inc(word)
            label_word_fd[label].inc(word)
    handle.seek(0)

def build_vocab(min_word_freq, positive_file, negative_file, nPos, nNeg):
    positive_handle = open(positive_file, 'r')
    negative_handle = open(negative_file, 'r')
    groups = [(1, positive_handle, nPos), (0, negative_handle, nNeg)]
    
    vocab = {}               
    for (curLabel, handle, limit) in groups:
        tweetsRead = 0;
        tweets = []
        for line in handle:
            if tweetsRead >= limit:
                break
            else:
                tweetsRead = tweetsRead + 1
                tweets.append(line)
                for word in words_in_tweet(line):
                    if vocab.has_key(word):
                        vocab[word] = vocab[word] + 1
                    else:
                        vocab[word] = 1;
        if tweetsRead != limit:
            print '***Warning: you requested ', limit, ' instances for label ', curLabel, ' but we only found ', tweetsRead, ' tweets with that label'
        handle.close()
        if curLabel == 0:
            negative_tweets = tweets
        elif curLabel == 1:
            positive_tweets = tweets
        
    wordId = {}
    nextId = 0
    for word in vocab.keys():
        if vocab[word] < min_word_freq:
            continue
        wordId[word] = nextId
        nextId = nextId +1
    return (wordId, positive_tweets, negative_tweets)
            
def build_csv(vocab, pos_tweets, negative_tweets, output_csv_file):
    nFeature = len(vocab)
    dataset = []

    for (label, tweets) in [(1, pos_tweets), (0, negative_tweets)]:
        for line in tweets:
            features = [0] * nFeature
            for word in words_in_tweet(line):
                if vocab.has_key(word): # it may not be in the vocab beucase of its low frequency overall
                    features[vocab[word]] = features[vocab[word]]+1
            dataset.append((label, line, features))
    random.shuffle(dataset)
    fd = open(output_csv_file+'.vis', 'w')
    fdet = open(output_csv_file+'.details', 'w')
    fdesc = open(output_csv_file+'.desc', 'w')
    fdict = open(output_csv_file+'.dict', 'w')
    
    fdesc.write('We transformed '+str(len(dataset))+' tweets, '+str(len(pos_tweets))+' postives and '+
                str(len(negative_tweets))+' negative tweets. Total number of features = '+str(nFeature)+'\n\n')
    fdesc.write('Format of '+output_csv_file+'.vis file is as follows:\n')
    fdesc.write('PrimaryKey, realLabel, feature1, ....feature'+str(nFeature)+'\n\n')
    fdesc.write('Format of '+output_csv_file+'.details file is as follows:\n')
    fdesc.write('PrimaryKey, realLabel, actual_tweat\n\n')
    fdesc.write('Format of '+output_csv_file+'.dict file is as follows:\n')
    fdesc.write('NumberOfTheFeature, CorrespondingWord\n\n')
    fdesc.close()
    
    for word, index in vocab.iteritems():
        fdict.write(str(index) + ':'+ word + '\n')
    fdict.close()
    
    for pk in range(len(dataset)):
        (label, tweet, features) = dataset[pk] 
        entries = map(str, features)
        fd.write(','.join([str(pk+1),str(label)])+','+','.join(entries)+'\n')
        fdet.write(str(pk+1)+','+str(label)+','+tweet)
    fd.close()
    fdet.close()
    print len(dataset), ' total lines were transformed into ', nFeature, ' features'
    
if __name__ == '__main__':
    if len(sys.argv) != 7:
        print 'Usage: tweet2csv.py positive_tweets negative_tweets howManyPositive howManyNegative output_file min_word_frequency'
        exit()
    pos_file = sys.argv[1]
    neg_file = sys.argv[2]
    nPos = int(sys.argv[3])
    nNeg = int(sys.argv[4])
    output_file = sys.argv[5]
    min_word_freq = int(sys.argv[6])
    
    (vocab, positive_tweets, negative_tweets) = build_vocab(min_word_freq, pos_file, neg_file, nPos, nNeg)
    print 'Vocabulary built, with ', len(vocab), ' words'
    build_csv(vocab, positive_tweets, negative_tweets, output_file)
    print 'follow do these commands:'
    print 'cp '+ output_file + '.* ~/bscripts/common_data/'
    print 'dataset = load(\'' + output_file + '.vis\', \'-ascii\');' 
    print 'save(\'~/bscripts/common_data/' + os.path.basename(output_file) + '.vis\', \'dataset\', \'-mat\', \'-v7.3\');'
    print 'Done!'
    
    
    

