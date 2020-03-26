module RSocks
  class Error < StandardError; end
  class NotSupport < Error; end
  class HttpAuthFailed < Error; end
end