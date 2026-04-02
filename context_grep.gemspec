Gem::Specification.new do |spec|
  spec.name         = "context_grep"
  spec.version      = "0.2.0"
  spec.summary      = "grep results with syntactic parent chains"

  spec.author       = "Victor Maslov aka Nakilon"
  spec.email        = "nakilon@gmail.com"
  spec.license      = "MIT"
  spec.metadata     = {"source_code_uri" => "https://github.com/nakilon/context_grep"}

  spec.add_dependency "github-linguist"
  spec.add_dependency "rubyzip"
  spec.add_dependency "ruby_tree_sitter"

  spec.files        = %w{ LICENSE context_grep.gemspec lib/context_grep.rb
                          exe/cogrep }
  spec.bindir       = %w{ exe }
  spec.executables  = %w{     cogrep }
end
