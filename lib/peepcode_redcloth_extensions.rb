module PeepCodeRedClothExtensions
  def shell(opts)
    "<pre>#{opts[:text]}</pre>"
  end
  alias_method :ruby, :shell
  alias_method :sql, :shell
end

RedCloth::Formatters::HTML.send :include, PeepCodeRedClothExtensions
