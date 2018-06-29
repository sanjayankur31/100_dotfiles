echo "Rebuilding YCM..."

pushd ~/.vim/plugged/YouCompleteMe
    find . -name "*pyc" -exec rm -fv '{}' \;
    # using system boost is breaking it somehow
    # python3 ./install.py --clang-completer --system-libclang --system-boost
    python3 ./install.py --clang-completer --system-libclang --js-completer --java-completer
popd
