module Sie
  class Parser
    class Entry
      attr_reader :label
      attr_accessor :attributes
      attr_accessor :entries

      def initialize(label)
        @label = label
        @attributes = {}
        @entries = []
      end
    end
  end
end
