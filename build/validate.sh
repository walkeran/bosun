#!/bin/bash
cd $GOPATH/src/bosun.org
DIRS=`find . -maxdepth 1 -type d -iregex './[^._].*'`

O=bosun-monitor
R=bosun
SHA=`git rev-parse ${TRAVIS_COMMIT}^2`
if [ "$TRAVIS" != '' ]; then
	setStatus -o $O -r $R -s pending -c fmt -d="Testing GoFmt" -sha=$SHA
	setStatus -o $O -r $R -s pending -c gen -d="Testing go generate" -sha=$SHA
	setStatus -o $O -r $R -s pending -c vet -d="Running Go vet" -sha=$SHA
	setStatus -o $O -r $R -s pending -c tests -d="Running Tests" -sha=$SHA
fi

echo -e "\nChecking gofmt -s -w for all folders that don't start with . or _"
GOFMTRESULT=0
GOFMTSTATUS=success
GOFMTMSG="go fmt ok"
GOFMTOUT=$(gofmt -l -s -w $DIRS);
if [ "$GOFMTOUT" != '' ]; then
    echo "The following files need 'gofmt -s -w':"
    echo "$GOFMTOUT"
    GOFMTRESULT=1
	GOFMTSTATUS=failure
	GOFMTMSG="go fmt -s needed"
fi

echo -e "\nRunning go vet bosun.org/..."
go vet bosun.org/...
GOVETRESULT=$?

echo -e "\nGetting esc"
go get -u -v github.com/mjibson/esc

echo -e "\nRunning go generate bosun.org/..."
go generate bosun.org/...
GOGENERATERESULT=$?
GOGENERATEDIFF=$(git diff --exit-code --name-only)
GOGENERATEDIFFRESULT=0
if [ "$GOGENERATEDIFF" != '' ]; then
    echo "Go generate needs to be run. The following files have changed:"
    echo "$GOGENERATEDIFF"
    GOGENERATEDIFFRESULT=1
fi

echo -e "\nRunning go test bosun.org/..."
go test bosun.org/...
GOTESTRESULT=$?

if [ "$TRAVIS" != '' ]; then
	setStatus -o $O -r $R -s $GOFMTRESULT -c fmt -d=$GOFMTMSG -sha=$SHA
fi

let "RESULT = $GOFMTRESULT | $GOVETRESULT | $GOTESTRESULT | $GOGENERATERESULT | $GOGENERATEDIFFRESULT"
exit $RESULT
