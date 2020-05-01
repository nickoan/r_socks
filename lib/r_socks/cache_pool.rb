module RSocks
  class CachePool

    def initialize
      @mutex = Mutex.new
      @pool = {}
    end

    def add(key, value)
      @mutex.synchronize do
        @pool[key] = value
      end
    end

    def del(key)
      @mutex.synchronize do
        @pool.delete(key)
      end
    end

    def del_with_condition(&blk)
      @mutex.synchronize do
        @pool.each do |k, v|
          result = blk.call(v)
          @pool.delete(k) if result
        end
      end
    end

  end
end