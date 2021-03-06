#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
if [ ! -d $JAVA_HOME ]
then
    export JAVA_HOME=/usr/lib/jvm/java-8-oracle
fi
export PATH=$JAVA_HOME/bin:$PATH

if [ ! -f stanford-postagger-full-2014-10-26.zip ]
then
    echo "Downloading POS Tagger…"
    wget http://nlp.stanford.edu/software/stanford-postagger-full-2014-10-26.zip
fi
echo "Installing POS Tagger"
unzip stanford-postagger-full-2014-10-26.zip

if [ ! -d CoreNLP ]
then
    echo "Cloning and installing CoreNLP…"
    git clone https://github.com/stanfordnlp/CoreNLP.git
    cd CoreNLP
    ant compile
    ant jar
    cd ..
fi
if ! ls stanford-english-corenlp-*models.jar 1> /dev/null 2>&1
then
    echo "Downloading English model for CoreNLP…"
    wget http://nlp.stanford.edu/software/stanford-english-corenlp-2016-01-10-models.jar
fi
yes | cp -l stanford-english-corenlp-*models.jar CoreNLP
echo "All seemed to work. Hold tight while we test it on a simple example (might take some time)."
cd CoreNLP
export CLASSPATH="`find . -name '*.jar'`"
java -mx4g -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer -port 9001 &
SERVER_PID=$!
sleep 1 # Let the server some time to start...
wget --post-data 'the quick brown fox jumped over the lazy dog' 'localhost:9001/?properties={"annotators": "tokenize,ssplit,pos", "outputFormat": "json"}' -O -
if [ $? -ne 0 ]
then
    echo "Something does not work…"
else
    echo "All seemed to work!"
fi
kill $SERVER_PID
