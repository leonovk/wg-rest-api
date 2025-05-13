# frozen_string_literal: true

module Factories
  class BaseFactory
    def self.build(add_params = {})
      new.build(add_params)
    end

    def build(add_params)
      repository.connection[table_name].insert(params.merge(add_params))
    end

    private

    attr_reader :table_name

    def repository
      WireGuard::Repository.new
    end
  end
end
