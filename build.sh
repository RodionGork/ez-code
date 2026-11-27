lang=$1
if [ "$lang" = "" ]; then
    lang="pl"
fi

files=("funclib" "ez2ast" "ast2out")

comment="#"
if [ $lang = "js" ]; then
    comment="//"
fi

result="${comment}generated file, don't edit directly"

libs="-lib"

for f in "${files[@]}"; do
    grep -q $'\t' $f.ez
    if [ "$?" = "0" ]; then
        echo "$f: tabs detected"
        exit 2
    fi
    output=$(./main.pl $f.ez -$lang $libs)
    if [ "$?" != "0" ]; then
        echo "$f: $output"
        exit 1
    fi
    result=$result$'\n'$output
    libs="-bare"
done

echo "$result" > generated/ez-code.$lang
