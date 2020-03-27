module RSocks
  class Error < StandardError; end
  class NotSupport < Error; end
  class HttpNotSupport < Error; end
  class HttpAuthFailed < Error; end
  class HealthChecking < StandardError; end
end