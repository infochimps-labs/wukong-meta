require 'wukong'

module Wukong
  # Produces metadata about deploy packs.
  module Meta
    include Plugin

    # Configure `settings` for Wukong-Meta.
    #
    # @param [Configliere::Param] settings the settings to configure
    # @param [String] program the currently executing program name
    def self.configure settings, program
      if program == 'wu-show'
        settings.define :to, :description => "Emit data as one of: text, json, tsv", :default => 'text'
      end
    end

    # Boot Wukong-Load from the resolved `settings` in the given
    # `dir`.
    #
    # @param [Configliere::Param] settings the resolved settings
    # @param [String] dir the directory to boot in
    def self.boot settings, dir
    end
    
  end
end

require_relative('wukong-meta/show_runner')
