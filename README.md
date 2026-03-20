# gem context_grep

It passes the query to the underlying grep (or ripgrep, if installed), and then prints not just "N lines of context" like you usually do, but the chains of syntactic parent lines for each match.

Usage:
```console
$ cogrep something
```


It requires at least Ruby 3.1 for the gem ruby_tree_sitter.

Currently it passes `.` as grep input.

For language detection, you need to install the gem github-linguist dependency according to your system. For example:
```
$ brew install icu4c 
```
