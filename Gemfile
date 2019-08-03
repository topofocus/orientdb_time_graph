source "https://rubygems.org"
#gemspec
## jruby support is experimental, not tested jet
#gem 'orientdb' , :git => 'git://github.com/topofocus/orientdb-jruby.git' , :platforms => :jruby
gem 'active-orient' , path: '../activeorient/' # :git => 'git://github.com/topofocus/active-orient.git'
gem 'pastel'

group :development, :test do
	gem "awesome_print"
	gem "rspec"
	gem 'rspec-legacy_formatters'
	gem 'rspec-its'
	gem 'rspec-collection_matchers'
	gem 'rspec-context-private'
	gem 'guard-jruby-rspec', :platforms => :jruby, :git => 'git://github.com/jkutner/guard-jruby-rspec.git'
	gem 'guard'#, :platforms => :ruby
	gem 'guard-rspec'
##	gem 'database_cleaner'
	gem 'rb-inotify'
	gem 'pry'
end
