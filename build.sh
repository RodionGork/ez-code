files=("funclib" "ez2ast" "ast2out")

result="#generated file, don't edit directly"

for f in "${files[@]}"; do
    grep -q $'\t' $f.ez
    if [ "$?" = "0" ]; then
        echo "$f: tabs detected"
        exit 2
    fi
    output=$(./main.pl $f.ez -bare)
    if [ "$?" != "0" ]; then
        echo "$f: $output"
        exit 1
    fi
    result=$result$'\n'$output
done

echo "$result" > ez-gen.pl
