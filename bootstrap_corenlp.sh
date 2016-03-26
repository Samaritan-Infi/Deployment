#!/bin/bash

USER_MODE="--user"
if [ $# -eq 1 ] && [ $1 == "--nouser" ]
then
    echo "No user mode."
    USER_MODE=""
fi

python3 -m pip install pexpect unidecode xmltodict jsonrpclib-pelix $USER_MODE

if [ ! -f corenlp-python ]
then
    echo "Cloning Valentin's modified corenlp-python library…"
    git clone https://bitbucket.org/ProgVal/corenlp-python.git
fi
echo "Installing it…"
cd corenlp-python
python3 setup.py install $USER_MODE
cd ..
if [ ! -f stanford-corenlp-full-2015-01-29.zip ]
then
    echo "Downloading CoreNLP (long: 221MB)…"
    wget http://nlp.stanford.edu/software/stanford-corenlp-full-2015-01-29.zip
fi
echo "Extracting CoreNLP…"
rm -rf stanford-corenlp-full-2015-01-29
unzip stanford-corenlp-full-2015-01-29.zip
echo "All seemed to work. Hold tight while we test it on a simple example (might take some time)."
CORENLP=stanford-corenlp-full-2015-01-30 python3 -c "print(repr(__import__('corenlp').StanfordCoreNLP().raw_parse('This is a sentence.')))"

if [ ! -f stanford-postagger-full-2014-10-26.zip ]
then
    echo "Downloading POS Tagger (long: 123MB)…"
    wget http://nlp.stanford.edu/software/stanford-postagger-full-2014-10-26.zip
fi
echo "Installing POS Tagger"
unzip stanford-postagger-full-2014-10-26.zip
python3 -c "import nltk; nltk.download('wordnet'); nltk.download('omw')"
