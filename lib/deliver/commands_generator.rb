require 'commander'
require 'deliver/download_screenshots'

HighLine.track_eof = false

module Deliver
  class CommandsGenerator
    include Commander::Methods

    def self.start
      # FastlaneCore::UpdateChecker.start_looking_for_update('deliver')
      # Deliver::DependencyChecker.check_dependencies
      self.new.run
    ensure
      # FastlaneCore::UpdateChecker.show_update_status('deliver', Deliver::VERSION)
    end

    def run
      program :version, Deliver::VERSION
      program :description, Deliver::DESCRIPTION
      program :help, 'Author', 'Felix Krause <deliver@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/krausefx/deliver'
      program :help_formatter, :compact

      FastlaneCore::CommanderGenerator.new.generate(Deliver::Options.available_options)

      global_option('--verbose') { $verbose = true }

      always_trace!

      command :run do |c|
        c.syntax = 'deliver'
        c.description = 'Upload metadata and binary to iTunes Connect'
        c.action do |args, options|
          options = FastlaneCore::Configuration.create(Deliver::Options.available_options, options.__hash__)
          options.load_configuration_file("Deliverfile")
          Deliver::Runner.new(options).run
        end
      end

      command :init do |c|
        c.syntax = 'deliver init'
        c.description = 'Create the initial `deliver` configuration based on an existing app'
        c.action do |args, options|
          if File.exist?("Deliverfile") or File.exist?("fastlane/Deliverfile")
            Helper.log.info "You already got a running deliver setup in this directory".yellow
            return
          end

          require 'deliver/setup'
          options = FastlaneCore::Configuration.create(Deliver::Options.available_options, options.__hash__)
          Deliver::Runner.new(options) # to login...
          Deliver::Setup.new.run(options)
        end
      end

      command :download_screenshots do |c|
        c.syntax = 'deliver download_screenshots'
        c.description = "Downloads all existing screenshots from iTunes Connect and stores them in the screenshots folder"

        c.action do |args, options|
          options = FastlaneCore::Configuration.create(Deliver::Options.available_options, options.__hash__)
          options.load_configuration_file("Deliverfile")
          Deliver::Runner.new(options) # to login...

          path = (FastlaneCore::Helper.fastlane_enabled? ? './fastlane' : '.')

          Deliver::DownloadScreenshots.run(options, path)
        end
      end

      default_command :run

      run!
    end
  end
end
