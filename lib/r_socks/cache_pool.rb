module RSocks
  class CachePool

    def initialize
      @mutex = Mutex.new
      @pool = {}
    end

    def get(key)
      @pool[key]
    end

    def add_object(key, value)
      value['time'] = Time.now.to_i
      @mutex.synchronize do
        @pool[key] = value
      end
    end

    def del(key)
      @mutex.synchronize do
        @pool.delete(key)
      end
    end

    def clear_with_time(time)
      @mutex.synchronize do
        @pool.each do |k, v|
          @pool.delete(k) if v['time'] < time
        end
      end
    end

  end
end