require "rubygems"
require "bundler"
require "fileutils"

Bundler.require(:default)

$:.unshift(File.join(File.dirname(__FILE__), "lib"))
require "peepcode_redcloth_extensions"

Dir.chdir(File.dirname(__FILE__))

# TODO: erb?
template = File.read("src/template.html")
source_files = Dir["src/peepcode-sphinx/text/*.textile"]

FileUtils.rm_rf("tmp/output")
FileUtils.rm_rf("tmp/build")
FileUtils.mkdir_p("tmp/output")
FileUtils.mkdir_p("tmp/build")

FileUtils.cp_r(Dir["src/*.css"], "tmp/output")
FileUtils.cp_r(Dir["src/peepcode-sphinx/artwork/*.png"], "tmp/output")

source_files.each do |source_file|
  source = File.read(source_file)
  html = template.sub("REPLACE ME", RedCloth.new(source).to_html)
  output_file = "tmp/output/#{source_file.gsub(/\.textile$/, '.html').gsub(/.*\//,'')}"
  File.open(output_file, "w+") {|f| f.write(html)}
end

# http://rubydoc.info/github/jugyo/eeepub/master/frames
epub = EeePub.make do
  title       'Thinking Sphinx'
  creator     'peepcode'
  publisher   'peepcode.com'
  date        '2010-05-06' # ??
  identifier  'http://peepcode.com/products/thinking-sphinx', :scheme => 'URL'
  uid         'http://peepcode.com/products/thinking-sphinx'

  files(Dir["tmp/output/*"])

  # TODO: build this automatically by parsing the files
  nav [
    {:label => '1. Introduction', :content => '1-introduction.html', :nav => []},
    {:label => '2. Understanding Sphinx', :content => '2-understanding-sphinx.html', :nav => []},
    {:label => '3. Installation', :content => '3-sphinx-installation.html', :nav => []},
    {:label => '4. Address Book Example', :content => '4-address-book-example.html', :nav => []},
    {:label => '5. References', :content => '5-reference.html', :nav => []},
    {:label => '6. Resources', :content => '6-resources.html', :nav => []},
  ]
end
epub.save('tmp/build/thinking-sphinx.epub')
