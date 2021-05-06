# From https://gist.github.com/nagapavan/22070c34522d15c072b7c258c09cb4ce/

function npm-freeze() {
    # npm ls | grep -E "^(├|└)─" | cut -d" " -f2 | awk -v quote='"' 'BEGIN { FS = "@" } ; { print quote $1 quote,":",quote $2 quote"," }' | sed -e 's/ :/:/g'
    entries=`npm list --depth=0 -prod true "$@" 2>/dev/null | grep -v "UNMET PEER DEPENDENCY\|peer dep missing" | grep -E "^(├|└)─" | cut -d" " -f2` 
    echo '"dependencies" : {'
    for entry in ${entries}; do
        if [[ $entry =~ ^@.* ]]; then
            # echo $entry
            echo $entry | awk -v quote='"' -v attherate='@' 'BEGIN { FS = "@" }; { print quote attherate $1$2 quote,":",quote $3 quote"," }'
        else
            echo $entry | awk -v quote='"' 'BEGIN { FS = "@" }; { print quote $1 quote,":",quote $2 quote"," }'
        fi
    done
    echo "},"

    entries=`npm list --depth=0 -dev true "$@" 2>/dev/null | grep -v "UNMET PEER DEPENDENCY\|peer dep missing" | grep -E "^(├|└)─" | cut -d" " -f2`
    echo '"devDependencies" : {'
    for entry in ${entries}; do
        if [[ $entry =~ ^@.* ]]; then
            # echo $entry
            echo $entry | awk -v quote='"' -v attherate='@' 'BEGIN { FS = "@" }; { print quote attherate $1$2 quote,":",quote $3 quote"," }'
        else
            echo $entry | awk -v quote='"' 'BEGIN { FS = "@" }; { print quote $1 quote,":",quote $2 quote"," }'
        fi
    done
    echo "},"
}


npm-freeze
