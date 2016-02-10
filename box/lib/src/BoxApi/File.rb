module BoxApi
  class File
    attr_reader :json
    def initialize(args={})
      @json = args[:json]
    end

    def name
      @name = @json["name"]
    end

  end
end

