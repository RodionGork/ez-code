files=("funclib" "ez2ast" "ast2out")

result="#generated file, don't edit directly"

libs="-lib"

for f in "${files[@]}"; do
    grep -q $'\t' $f.ez
    if [ "$?" = "0" ]; then
        echo "$f: tabs detected"
        exit 2
    fi
    output=$(./main.pl $f.ez $libs)
    if [ "$?" != "0" ]; then
        echo "$f: $output"
        exit 1
    fi
    result=$result$'\n'$output
    libs="-bare"
done

echo "$result" > ez-gen.pl
