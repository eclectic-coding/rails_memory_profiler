module RailsMemoryProfiler
  # Thread-safe circular buffer that holds per-request profiling reports.
  # Capacity is controlled by {Configuration#store_size}. When full, the oldest
  # report is evicted to make room for each new one.
  #
  # Each report is a Hash with the keys:
  # - +:id+ — unique hex string assigned on push
  # - +:path+, +:method+, +:controller+, +:action+
  # - +:allocated_objects+, +:retained_objects+
  # - +:duration_ms+
  # - +:recorded_at+ — +Time+ of capture
  # - +:detail+ — optional breakdown Hash (present when {Configuration#detailed_reports} is enabled)
  module ReportStore
    MUTEX = Mutex.new
    private_constant :MUTEX

    class << self
      # Adds a report to the buffer, assigning a unique +:id+ key.
      # Evicts the oldest entry when the buffer is at capacity.
      #
      # @param report [Hash] profiling data without an +:id+ key
      # @return [void]
      def push(report)
        mutex.synchronize do
          ensure_buffer_size
          buffer[@write_pos] = report.merge(id: SecureRandom.hex(6))
          @write_pos = (@write_pos + 1) % capacity
          @stored    = [@stored + 1, capacity].min
        end
      end

      # Returns the report with the given id, or +nil+ if not found or evicted.
      #
      # @param id [String]
      # @return [Hash, nil]
      def find(id)
        all.find { |r| r[:id] == id }
      end

      # Returns all stored reports in insertion order (oldest first).
      #
      # @return [Array<Hash>]
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

      # Removes all stored reports.
      #
      # @return [void]
      def clear
        mutex.synchronize { reset! }
      end

      # Returns the number of reports currently stored.
      #
      # @return [Integer]
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
