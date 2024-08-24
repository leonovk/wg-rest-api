# frozen_string_literal: true

require 'git'

module CI
  # Class for bump version in CI
  class Bumper
    def initialize
      repo = Git.open('.')
      @commit = repo.log.first
    end

    def bump?
      commit.diff_parent.name_status.each_key do |file|
        return false if file == 'VERSION'

        path = file.split('/').first
        case path
        when 'lib', 'app', 'config', 'tasks', 'app.rb', 'config.ru', 'Dockerfile'
          return true
        end
      end

      false
    end

    def bump_pathc_version
      version = File.read('VERSION').gsub('v', '')
      semver = version.split('.')
      new_pathc = semver.last.to_i + 1
      semver[2] = new_pathc.to_s
      new_version = "v#{semver.join('.')}"
      File.write('VERSION', new_version)
    end

    private

    attr_reader :commit
  end
end

namespace :ci do
  desc 'bump pathc version'
  task :bump_pathc_version do
    bumper = CI::Bumper.new

    bumper.bump_pathc_version if bumper.bump?
  end
end
