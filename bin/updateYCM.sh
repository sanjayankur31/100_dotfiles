echo "Rebuilding YCM..."

pushd ~/.vim/bundle/YouCompleteMe
    find . -name "*pyc" -exec rm -fv '{}' \;
    python3 ./install.py --clang-completer --system-libclang --system-boost
popd
