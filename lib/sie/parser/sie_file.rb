module Sie
  class Parser
    class SieFile
      def entries_with_label(label)
        entries.select { |entry| entry.label == label }
      end

      def entries
        @entries ||= []
      end
    end
  end
end
