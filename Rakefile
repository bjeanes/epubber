desc "check the ePub files for errors"
task :check do
  Dir.chdir(File.dirname(__FILE__))

  Dir["tmp/build/*.epub"].each do |epub|
    puts `java -jar vendor/epubcheck-1.0.5/epubcheck-1.0.5.jar #{epub}`
  end
end
