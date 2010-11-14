require "date"

module Epubber
  class Book
    attr_accessor :build_path, :output_path, :source_path

    def initialize(source_path, build_path, output_path)
      self.source_path = source_path
      self.build_path  = build_path
      self.output_path = output_path
    end

    def save
      FileUtils.rm_rf("tmp")
      FileUtils.mkdir_p(output_path)
      FileUtils.mkdir_p(build_path)

      FileUtils.cp_r(Dir["src/*.css"], build_path)
      FileUtils.cp_r(Dir[File.join(source_path, "artwork", "*.png")], build_path)

      @epub.save(output_filename)
      output_filename
    end

    def source_text_files
      @source_text_files ||= Dir[File.join(source_path, "text", "*.textile")]
    end

    def epub
      # http://rubydoc.info/github/jugyo/eeepub/master/frames
      @epub ||= EeePub.make do
        title       epub_title
        creator     epub_creator
        publisher   epub_publisher
        date        epub_date
        identifier  epub_url, :scheme => 'URL'
        uid         epub_url
        files       epub_files
        nav         epub_nav
      end
    end

    def output_filename
      File.join(output_path, "#{param}.epub")
    end

    def epub_title
      "Thinking Sphinx"
    end

    def epub_creator
      "Pat Allan"
    end

    def epub_publisher
      "PeepCode"
    end

    def epub_date
      Date.today.to_s
    end

    def epub_url
      "http://peepcode.com/products/#{param}"
    end

    def param
      title.downcase.gsub(/[^a-z0-9]/, "-")
    end

    def epub_files
      Dir[File.join(build_path, "*")]
    end

    def epub_nav
      [
        {:label => '1. Introduction', :content => '1-introduction.html', :nav => []},
        {:label => '2. Understanding Sphinx', :content => '2-understanding-sphinx.html', :nav => []},
        {:label => '3. Installation', :content => '3-sphinx-installation.html', :nav => []},
        {:label => '4. Address Book Example', :content => '4-address-book-example.html', :nav => []},
        {:label => '5. References', :content => '5-reference.html', :nav => []},
        {:label => '6. Resources', :content => '6-resources.html', :nav => []},
      ]
    end

  ## TODO: erb?
  #template = File.read("src/template.html")
  #
  #
  #
  #FileUtils.rm_rf("tmp/output")
  #FileUtils.rm_rf("tmp/build")
  #FileUtils.mkdir_p("tmp/output")
  #FileUtils.mkdir_p("tmp/build")
  #
  #FileUtils.cp_r(Dir["src/*.css"], "tmp/output")
  #FileUtils.cp_r(Dir["src/peepcode-sphinx/artwork/*.png"], "tmp/output")
  #
  #source_files.each do |source_file|
  #  source = File.read(source_file)
  #  html = template.sub("REPLACE ME", RedCloth.new(source).to_html)
  #  output_file = "tmp/output/#{source_file.gsub(/\.textile$/, '.html').gsub(/.*\//,'')}"
  #  File.open(output_file, "w+") {|f| f.write(html)}
  #end
  #
  ## http://rubydoc.info/github/jugyo/eeepub/master/frames
  #epub = EeePub.make do
  #  title       'Thinking Sphinx'
  #  creator     'peepcode'
  #  publisher   'peepcode.com'
  #  date        '2010-05-06' # ??
  #  identifier  'http://peepcode.com/products/thinking-sphinx', :scheme => 'URL'
  #  uid         'http://peepcode.com/products/thinking-sphinx'
  #
  #  files(Dir["tmp/output/*"])
  #
  #  # TODO: build this automatically by parsing the files
  #  nav [
  #    {:label => '1. Introduction', :content => '1-introduction.html', :nav => []},
  #    {:label => '2. Understanding Sphinx', :content => '2-understanding-sphinx.html', :nav => []},
  #    {:label => '3. Installation', :content => '3-sphinx-installation.html', :nav => []},
  #    {:label => '4. Address Book Example', :content => '4-address-book-example.html', :nav => []},
  #    {:label => '5. References', :content => '5-reference.html', :nav => []},
  #    {:label => '6. Resources', :content => '6-resources.html', :nav => []},
  #  ]
  #end
  #epub.save('tmp/build/thinking-sphinx.epub')
  end
end
