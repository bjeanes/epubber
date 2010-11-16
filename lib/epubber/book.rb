require "date"
require "fileutils"
require "tmpdir"
require "peep_code_formatter"

module Epubber
  class Book
    attr_accessor :build_path, :output_path, :source_path

    def initialize(source_path, output_path)
      self.source_path = source_path
      self.output_path = output_path
    end

    def transform_textile_to_html
      epub_files.each do |source_file, html_file|
        html_file = File.join(build_path, html_file)
        textile   = RedCloth.new(File.read(source_file)).to_peepcode_html(code_path)
        html      = template.sub("REPLACE ME", textile) # TODO: erb?
        File.open(html_file, "w+") {|f| f.write(html)}
      end
    end

    def template
      @template ||= File.read("src/template.html")
    end

    def code_path
      File.expand_path(File.join(source_path, "code"))
    end

    def build_path
      @build_path ||= File.join(Dir.tmpdir, "epubber", File.basename(source_path))
    end

    def bundle_assets
      FileUtils.cp_r(Dir["src/*.css"], build_path)
      FileUtils.cp_r(Dir["src/fonts/*.otf"], build_path)
      FileUtils.cp_r(Dir["src/fonts/*.ttf"], build_path)
      FileUtils.cp_r(Dir[File.join(source_path, "artwork", "*.png")], build_path)
    end

    def create_directories
      FileUtils.rm_rf(output_path)
      FileUtils.mkdir_p(output_path)
      FileUtils.mkdir_p(build_path)
    end

    def save
      create_directories
      bundle_assets
      transform_textile_to_html
      epub.save(output_filename)
      FileUtils.rm_rf(build_path)
      output_filename
    end

    def epub_files
      @files ||= Dir[File.join(source_path, "text", "*.textile")].map do |file|
        [file, file.gsub(/.*\/(.*)\.textile/, '\1.html')]
      end
    end

    def source_text_files
      files.keys
    end

    def epub
      # http://rubydoc.info/github/jugyo/eeepub/master/frames
      @epub ||= begin
        EeePub.make.tap do |epub|
          epub.title      title
          epub.creator    creator
          epub.publisher  publisher
          epub.date       date
          epub.identifier url, :scheme => 'URL'
          epub.uid        url
          epub.files      files
          epub.nav        nav
        end
      end
    end

    def output_filename
      File.join(output_path, "#{param}.epub")
    end

    # TODO: automatically figure this out (normalize folder name?)
    def title
      "Thinking Sphinx"
    end

    # TODO: automatically figure this out
    def creator
      "Pat Allan"
    end

    def publisher
      "PeepCode"
    end

    def date
      Date.today.to_s
    end

    def url
      "http://peepcode.com/products/#{param}"
    end

    def param
      title.downcase.gsub(/[^a-z0-9]/, "-")
    end

    def files
      Dir[File.join(build_path, "*")]
    end

    # TODO: automatically figure this out (override textile h1-h6 methods to record?)
    def nav
      [
        {:label => '1. Introduction', :content => '1-introduction.html', :nav => []},
        {:label => '2. Understanding Sphinx', :content => '2-understanding-sphinx.html', :nav => []},
        {:label => '3. Installation', :content => '3-sphinx-installation.html', :nav => []},
        {:label => '4. Address Book Example', :content => '4-address-book-example.html', :nav => []},
        {:label => '5. References', :content => '5-reference.html', :nav => []},
        {:label => '6. Resources', :content => '6-resources.html', :nav => []},
      ]
    end
  end
end
