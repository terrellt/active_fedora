class CompositeProxy
  attr_reader :ids, :factory
  def initialize(ids:, factory:)
    @ids = IDComposite.new(ids, factory.translate_uri_to_id)
    @factory = factory
  end

  def each
    ids.each do |id|
      yield factory.find(id)
    end
  end

  def delete
    self.each(&:delete)
  end

  class IDComposite
    attr_reader :ids, :id_translator
    def initialize(ids, id_translator)
      @ids = ids
      @id_translator = id_translator
    end

    def each
      ids.each do |id|
        yield convert(id)
      end
    end

    private

    def convert(id)
      if id.start_with?("http")
        id_translator.call(id)
      else
        id
      end
    end
  end
end
