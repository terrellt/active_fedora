module ActiveFedora::Associations
  class RecordProxyFinder
    attr_reader :container, :factory
    delegate :contained_ids, to: :container
    def initialize(container:, factory:)
      @container = container
      @factory = factory
    end

    def find(record)
      record.reload
      factory.find(matching_ids(record))
    end

    private

    def matching_ids(record)
      IDComposite.new(proxy_ids(record) & contained_ids, factory.translate_uri_to_id)
    end

    def proxy_ids(record)
      relation_subjects(record)
    end

    def relation_subjects(record)
      record.resource.query(object: record.rdf_subject).subjects.to_a
    end
  end

  class IDComposite
    attr_reader :ids, :id_translator
    include Enumerable
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
