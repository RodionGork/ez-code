funclib=$(./main.pl funclib.ez -bare)
if [ "$?" != "0" ]; then
    echo $funclib
    exit 1
fi

ez2ast=$(./main.pl ez2ast.ez -bare)
if [ "$?" != "0" ]; then
    echo $ez2ast
    exit 1
fi

ast2out=$(./main.pl ast2out.ez -bare)
if [ "$?" != "0" ]; then
    echo $ast2out
    exit 1
fi

echo "$funclib" > ez-gen.pl
echo "$ez2ast" >> ez-gen.pl
echo "$ast2out" >> ez-gen.pl
