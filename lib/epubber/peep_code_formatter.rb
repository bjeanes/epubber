module PeepCodeFormatter
  include RedCloth::Formatters::HTML

  def code(opts)
    # TODO: if opts[:text] is an existent filename, read the file and return that content in <code> blocks
    file        = File.join(code_path, opts[:text])
    opts[:text] = File.read(file) if File.exists?(file)

    super(opts)
  end

  [:ruby, :sql, :erb, :filename, :shell].each do |method|
    define_method(method) do |opts|
      code(opts)
    end
  end
end

module RedCloth
  class TextileDoc
    #
    # Generates HTML for inclusion in an ePub from the Textile contents.
    #
    def to_peepcode_html(code_path, *rules)
      apply_rules(rules)
      @code_path = code_path
      to(PeepCodeFormatter)
    end

    private
    def code_path
      @code_path || ""
    end
  end
end
