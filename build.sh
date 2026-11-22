ez2ast=$(./main.pl ez2ast.ez -bare)
if [ "$?" != "0" ]; then
    echo $ez2ast
    exit 1
fi

ast2out=$(./main.pl ast2out.ez -bare)
if [ "$?" != "0" ]; then
    echo $ez2ast
    exit 1
fi

echo "$ez2ast" > ez2ast-gen.pl
echo "$ast2out" > ast2out-gen.pl
