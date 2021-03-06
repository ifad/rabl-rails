ENV['RAILS_ENV'] = 'test'
$:.unshift File.expand_path('../../lib', __FILE__)

require 'coveralls'
Coveralls.wear!

# require 'rspec/mocks'
require 'minitest/mock'
require 'minitest/autorun'

require 'rabl-rails'
require 'plist'
require 'action_dispatch/http/mime_type'
require 'action_view'

if RUBY_ENGINE == 'jruby'
  require 'nokogiri'
elsif RUBY_ENGINE == 'ruby'
  require 'libxml'
end

ActionView::Template.register_template_handler :rabl, RablRails::Handlers::Rabl

module Configurable
  def with_configuration(key, value)
    accessor = "#{key}="
    old_value = RablRails.configuration.send(key)
    RablRails.configuration.send(accessor, value)
    yield
  ensure
    RablRails.configuration.send(accessor, old_value)
  end
end
Minitest::Test.send(:include, Configurable)

module Rails
  def self.cache
  end
end

module ActionController
  module Base
    def self.perform_caching
      false
    end
  end
end

class Context
  class Request
    def initialize(format)
      @format = format
    end

    def format
      OpenStruct.new(symbol: @format.to_sym)
    end
  end

  attr_writer :virtual_path
  attr_reader :request

  def initialize(format = :json)
    @_assigns = {}
    @virtual_path = nil
    @request = Request.new(format)
  end

  def assigns
    @_assigns
  end

  def params
    {}
  end

  def context_method
  end
end

class User
  attr_accessor :id, :name

  def initialize(id = nil, name = nil)
    @id = id
    @name = name
  end
end
