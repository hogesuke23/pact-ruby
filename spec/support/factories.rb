require 'hashie'
require 'hashie/extensions/key_conversion'

module Pact
  module HashUtils

    class Converter < Hash
      include Hashie::Extensions::KeyConversion
      include Hashie::Extensions::DeepMerge
    end

    def symbolize_keys hash
      Hash[Converter[hash].symbolize_keys]
    end

    def stringify_keys hash
      Hash[Converter[hash].stringify_keys]
    end

    def deep_merge hash1, hash2
      Converter[hash1].deep_merge(Converter[hash2])
    end
  end
end

class InteractionFactory

  extend Pact::HashUtils

  DEFAULTS = Hash[
    'request' => {
      'path' => '/path',
      'method' => 'get',
    },
    'response' => {
      'body' => {a: 'response body'}
    },
    'description' => 'a description',
    'provider_state' => 'a thing exists'
  ]

  def self.create hash = {}
    Pact::Interaction.from_hash(stringify_keys(deep_merge(DEFAULTS, stringify_keys(hash))))
  end
end


class ConsumerContractFactory
  extend Pact::HashUtils
  DEFAULTS = {:consumer_name => 'consumer',
      :provider_name => 'provider',
      :interactions => [InteractionFactory.create]}

  def self.create overrides = {}
    options = deep_merge(symbolize_keys(DEFAULTS), symbolize_keys(overrides))
    Pact::ConsumerContract.new({:consumer => Pact::ServiceConsumer.new(name: options[:consumer_name]),
      :provider => Pact::ServiceProvider.new(name: options[:provider_name]),
      :interactions => options[:interactions]})
  end
end



class ResponseFactory
  extend Pact::HashUtils
  DEFAULTS = {:status => 200, :body => {a: 'body'}}.freeze
  def self.create_hash overrides = {}
    deep_merge(DEFAULTS, overrides)
  end
end

class RequestFactory
  extend Pact::HashUtils
  DEFAULTS = {:path => '/path', :method => 'get'}.freeze
  def self.create_hash overrides = {}
   deep_merge(DEFAULTS, overrides)
  end
end