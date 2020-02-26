module Delighted
  class ListResource
    def initialize(klass, path, opts, client)
      @class = klass
      @path = path
      @opts = opts
      @client = client
      @iteration_count = 0
      @done = false
    end

    def auto_paging_each(opts = {})
      raise PaginationError, "pagination completed" if @done

      auto_handle_rate_limits = opts.fetch(:auto_handle_rate_limits, false)
      loop do
        begin
          # Get next (or first) page
          if @iteration_count == 0
            data = @client.request_get(@path, { params: @opts })
          else
            data = @client.request_get(@next_link)
          end
        rescue Delighted::RateLimitedError => e
          if auto_handle_rate_limits
            sleep e.retry_after
            retry
          else
            raise
          end
        end

        @iteration_count += 1
        @next_link = data[:response].next_link

        data[:json].map do |attributes|
          yield @class.new(attributes)
        end

        break if @next_link.nil?
      end
      @done = true
    end
  end
end
