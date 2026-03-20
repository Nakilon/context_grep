# gem context_grep

It passes the query to the underlying grep (or ripgrep, if installed), and then prints not just "N lines of context" like you usually do, but the chains of syntactic parent lines for each match.

Usage:
```console
$ cogrep something
```

The following example demonstrates:
1. how it merges multiple matched lines from one file
2. how it relies on actual syntax, not indentation
3. how to run it with ruby >= 3.1 (required for the gem ruby_tree_sitter) if your local is lower, in case of rbenv

<img width="1401" height="494" alt="image" src="https://github.com/user-attachments/assets/9d94479f-9979-4d29-a46a-aa9774750a30" />

Currently it passes `.` as grep input.

For language detection, you need to install the gem github-linguist dependency according to your system. For example:
```
$ brew install icu4c 
```
