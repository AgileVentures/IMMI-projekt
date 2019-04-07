ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.


# Note: 2019-02-23: In ruby 2.5.1 and 2.5.2 (fixed in 2.5.3)
# IDE debugger (RubyMine) will not stop at breakpoints in Controller classes
# unless you comment out the "require 'bootsnap/setup'" line below
#
# Bug in ruby: https://bugs.ruby-lang.org/issues/14702
#   see discussion in rails/rails for more info and this workaround:
#      https://github.com/rails/rails/issues/32737#issuecomment-388763226
#
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
