require "linguist"
require "pathname"  # undefined method `Pathname' for TreeSitter:Module (NoMethodError)
require "tree_stand"
::TreeStand.config.parser_path = ::File.expand_path "~/.context_grep"

require "fileutils"
ZIP_FILENAME = ::File.join ::TreeStand.config.parser_path, "temp.zip"
def ContextGrep what, where = "."

  `#{system("rg --version >/dev/null 2>&1") ? "rg -n" : "grep -nrI"} #{what} #{where} 2>/dev/null`
  .scan(/^([^:]+):(\d+):/).group_by(&:first).map do |file, group|
    lang = ::Linguist::FileBlob.new(file).language
    next ::STDERR.puts "unsupported grammar #{lang} at #{file}" unless ts_name = {
        "Bash" => "bash",
        "C" => "c",
        "C#" => "c_sharp",
        "COBOL" => "cobol",
        "Groovy" => "groovy",
        "Haml" => "haml",
        "HTML" => "html",
        "Java" => "java",
        "JavaScript" => "javascript",
        "JSON" => "json",
        "Pascal" => "pascal",
        "PHP" => "php",
        "Python" => "python",
        "Ruby" => "ruby",
        "Rust" => "rust",
        "XML" => "xml",
    }[lang.name]
    src = ::File.read file
    stack = [
      begin
        ::TreeStand::Parser.new ts_name
      rescue ::TreeSitter::ParserNotFoundError
        ::FileUtils.mkdir_p ::TreeStand.config.parser_path
        require "etc"
        require "open-uri"
        "https://github.com/Faveod/tree-sitter-parsers/releases/download/v5.0/tree-sitter-parsers-5.0-#{
          "Darwin" == ::Etc.uname[:sysname] ? "macos" : "linux"
        }-#{
          ::RbConfig::CONFIG["host_cpu"] =~ /x86_64|amd64/ ? "x64" : "arm64"
        }.zip".tap do |url|
            ::STDERR.puts "downloading #{url} to #{::TreeStand.config.parser_path}"
          ::File.binwrite ZIP_FILENAME, ::URI.open(url, &:read)
        end unless File.exist? ZIP_FILENAME
        require "zip"
        lambda do
          ::Zip::File.open(ZIP_FILENAME) do |zip|
          for entry in zip
            next if entry.directory?
            target_path = ::File.join ::TreeStand.config.parser_path, ::File.basename(entry.name)
              next if ::File.exists? target_path
            entry.extract target_path
              begin
                return ::TreeStand::Parser.new ts_name
              rescue ::TreeSitter::ParserNotFoundError
                ::FileUtils.rm_f target_path
              end
          end
          end
          nil
        end.call or next ::STDERR.puts "can't find grammar library for #{lang} at #{file}"
      end.parse_string(src).root_node
    ]
    nodes = {}
    for node in stack
      stack.concat node.children.each{ |_| nodes[_] = node }
    end
    [
      file,
      group.flat_map do |_, grep_lineno|
        node = nodes.keys
        .select{ |_| _.ts_node.start_point.row <= grep_lineno.to_i - 1 && grep_lineno.to_i - 1 <= _.ts_node.end_point.row }
        .max_by{ |_| _.ts_node.start_byte } || fail
        [].tap do |lines|
          begin
            if ::ENV["COGREP_DEBUGTYPES"]
              s = node.ts_node.start_point.row + 1
              e = node.ts_node.end_point.row + 1
              ::STDERR.puts "#{::File.basename file} #{node.type.inspect} #{s}-#{e}: #{src.lines[s - 1]}"
            end
            lines.push node.ts_node.start_point.row unless %i{ program body_statement translation_unit }.include? node.type
          end while node = nodes[node]
        end
      end.uniq.sort.map{ |_| [_ + 1, src.lines[_]] }
    ]
  end.compact

ensure
  ::FileUtils.rm_f ZIP_FILENAME
end
