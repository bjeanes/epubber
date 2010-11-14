module PeepCodeRedClothExtensions
  def shell(opts)
    # TODO: if opts[:text] is an existent filename, read the file and return that content in <code> blocks
    $stdout.send :p, opts[:text]
    "<pre>#{opts[:text]}</pre>"
  end
  alias_method :ruby, :shell
  alias_method :sql, :shell
end
