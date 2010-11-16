require "rubygems"
require "bundler"

Bundler.require(:default)

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "epubber")))

require "book"

ROOT_PATH   = File.expand_path(File.join(File.dirname(__FILE__), ".."))
OUTPUT_PATH = File.join(ROOT_PATH, "tmp", "output")
