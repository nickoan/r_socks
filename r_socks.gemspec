require_relative 'lib/r_socks/version'

Gem::Specification.new do |spec|
  spec.name          = "r_socks"
  spec.version       = RSocks::VERSION
  spec.authors       = ["Nick An"]
  spec.email         = ["anning0322@gmail.com"]
  spec.licenses      = ['Apache-2.0']

  spec.summary       = %q{socks5 proxy server}
  spec.description   = %q{ruby socks5 and http proxy}
  spec.homepage      = "https://github.com/nickoan/r_socks"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nickoan/r_socks"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'eventmachine', '~> 1.2', '>= 1.2.7'
  spec.add_runtime_dependency 'redis', '~> 4.1', '>= 4.1.4'
end
