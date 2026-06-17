module RailsMemoryProfiler
  module ReportStore
    MUTEX = Mutex.new
    private_constant :MUTEX

    class << self
      def push(report)
        mutex.synchronize do
          ensure_buffer_size
          buffer[@write_pos] = report.merge(id: SecureRandom.hex(6))
          @write_pos = (@write_pos + 1) % capacity
          @stored    = [@stored + 1, capacity].min
        end
      end

      def find(id)
        all.find { |r| r[:id] == id }
      end

      def all
        mutex.synchronize do
          stored = @stored || 0
          return [] if stored.zero?

          if stored < capacity
            buffer.first(stored)
          else
            buffer[@write_pos..] + buffer[0...@write_pos]
          end
        end
      end

      def clear
        mutex.synchronize { reset! }
      end

      def size
        mutex.synchronize { @stored || 0 }
      end

      private

        def mutex
          MUTEX
        end

        def capacity
          RailsMemoryProfiler.config.store_size
        end

        def ensure_buffer_size
          reset! if @write_pos.nil? || @buffer.nil? || @buffer.size != capacity
        end

        def buffer
          @buffer ||= Array.new(capacity)
        end

        def reset!
          @buffer    = Array.new(capacity)
          @write_pos = 0
          @stored    = 0
        end
    end
  end
end
