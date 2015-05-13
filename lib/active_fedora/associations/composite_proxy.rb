module ActiveFedora::Associations
  class CompositeProxy
    attr_reader :proxies
    def initialize(proxies:)
      @proxies = proxies
    end

    def each
      proxies.each do |proxy|
        yield proxy
      end
    end

    def delete
      self.each(&:delete)
    end
    class Factory
      attr_reader :base_factory
      delegate :translate_uri_to_id, to: :base_factory
      def initialize(factory:)
        @base_factory = factory
      end

      def find(ids)
        proxies = ids.map do |id|
          base_factory.find(id)
        end
        CompositeProxy.new(proxies: proxies)
      end
    end
  end
end
