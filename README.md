# gem context_grep

It passes the query to the underlying grep (or ripgrep, if installed), and then prints not just "N lines of context" like you usually do, but the chains of syntactic parent lines for each match.

## Installation

```console
$ brew install icu4c       # for github-linguist, install in the way according to your system
$ gem install context_grep
```

## Usage

```console
$ cogrep PATTERN [PATH]
```

## Examples

1. example shows that it skips unsupported grammars
    ```none
    ruby-tree-sitter $ cogrep segfa
                                                                                
    unsupported grammar Markdown at ./docs/SIGSEGV.md
    
    ./ext/tree_sitter/node.c
     308 static VALUE node_field_name_for_child(VALUE self, VALUE idx) {
     311   // this way to avoid segfault. Should we absolutely stick to the original API?
    
    ./Rakefile
      13 # NOTE: bundler is segfaulting on:
    
    ./test/tree_sitter/node_test.rb
     121 describe 'parent' do
     122   # NOTE: never call parent on root. It will segfault.
    ```

2. example demonstrates passing a regex pattern and path for grepping, also multiline parents (3-4)
    ```none
    $ cogrep '[^a-zA-Z]BuyerItemCode' ..

    ../foobar/schema.xml
       1 <?xml version="1.0" encoding="UTF-8"?>
       3 <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified"
       4           attributeFormDefault="unqualified" version="0.6">
      29    <xs:element name="BuyerItemCode" type="string26"/>
     139    <xs:element name="Line-Item">
     140        <xs:complexType>
     141            <xs:choice maxOccurs="unbounded">
     146                <xs:element ref="BuyerItemCode" minOccurs="0"/>
    ```

3. example demonstrates how
    1. it merges multiple matched lines from one file
    2. it relies on actual syntax, not indentation
    3. to run it with ruby >= 3.1 (required for the gem ruby_tree_sitter) if your local is lower, in case of rbenv
    
    <img width="1401" height="494" alt="image" src="https://github.com/user-attachments/assets/9d94479f-9979-4d29-a46a-aa9774750a30" />

## Additional grammars

You might see the following:
```none
can't find grammar library for XML at ...
```
Unfortunately the tree-sitter community does not provide precompiled grammars so if one is not listed here https://github.com/Faveod/tree-sitter-parsers/blob/v5.0/parsers.toml it should be chosen from https://github.com/tree-sitter/tree-sitter/wiki/List-of-parsers, and downloaded/compiled manually. For example:
```console
$ git clone https://github.com/tree-sitter-grammars/tree-sitter-xml
$ cd tree-sitter-xml
$ npm install tree-sitter
$ make
$ cp xml/libtree-sitter-xml.dylib ~/.context_grep/
```

## Development:

```console
$ rake -rbundler/gem_tasks release
```
