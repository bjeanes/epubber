require "date"

module Epubber
  class Book
    attr_accessor :build_path, :output_path, :source_path

    def initialize(source_path, build_path, output_path)
      self.source_path = source_path
      self.build_path  = build_path
      self.output_path = output_path

      transform_textile_to_html
    end

    def transform_textile_to_html
      epub_files.each do |source_file, html_file|
        source = RedCloth.new(File.read(source_file))
        source.extend(PeepCodeRedClothExtensions)
        html = template.sub("REPLACE ME", source.to_html) # TODO: erb?
        File.open(File.join(build_path, html_file), "w+") {|f| f.write(html)}
      end
    end

    def template
      @template ||= File.read(File.join(source_path, "..", "..", "template.html"))
    end

    def save
      FileUtils.rm_rf("tmp")
      FileUtils.mkdir_p(output_path)
      FileUtils.mkdir_p(build_path)

      FileUtils.cp_r(Dir["src/*.css"], build_path)
      FileUtils.cp_r(Dir[File.join(source_path, "artwork", "*.png")], build_path)

      epub.save(output_filename)
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
      epub = self
      @epub ||= EeePub.make do
        title       epub.title
        creator     epub.creator
        publisher   epub.publisher
        date        epub.date
        identifier  epub.url, :scheme => 'URL'
        uid         epub.url
        files       epub.files
        nav         epub.nav
      end
    end

    def output_filename
      File.join(output_path, "#{param}.epub")
    end

    def title
      "Thinking Sphinx"
    end

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

    # TODO: automatically figure this out
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
