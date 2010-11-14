require "rubygems"
require "bundler"

Bundler.require(:default)

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "epubber")))

require "book"

ROOT_PATH   = File.expand_path(File.join(File.dirname(__FILE__), ".."))
BUILD_PATH  = File.join(ROOT_PATH, "tmp", "build")
OUTPUT_PATH = File.join(ROOT_PATH, "tmp", "output")

if __FILE__ == $0
  abort "Please provide path to PeepCode book as first argument" unless ARGV.size > 0

  book_path = ARGV.shift
  book = Epubber::Book.new(book_path, BUILD_PATH, OUTPUT_PATH)
  location = book.save

  puts "#{File.expand_path(book_path)} saved to #{File.expand_path(location)}"
end
