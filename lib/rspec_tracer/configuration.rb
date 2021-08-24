# frozen_string_literal: true

require_relative 'filter'

module RSpecTracer
  module Configuration
    DEFAULT_CACHE_DIR = 'rspec_tracer_cache'
    DEFAULT_COVERAGE_DIR = 'rspec_tracer_coverage'

    attr_writer :filters, :coverage_filters

    def root(root = nil)
      return @root if defined?(@root) && root.nil?

      @cache_path = nil
      @root = File.expand_path(root || Dir.getwd)
    end

    def cache_dir(dir = nil)
      return @cache_dir if defined?(@cache_dir) && dir.nil?

      @cache_path = nil
      @cache_dir = dir || DEFAULT_CACHE_DIR
    end

    def cache_path
      @cache_path ||= begin
        cache_path = File.expand_path(cache_dir, root)
        cache_path = File.join(cache_path, ENV['TEST_SUITE_ID'].to_s)

        FileUtils.mkdir_p(cache_path)

        cache_path
      end
    end

    def coverage_dir(dir = nil)
      return @coverage_dir if defined?(@coverage_dir) && dir.nil?

      @coverage_path = nil
      @coverage_dir = dir || DEFAULT_COVERAGE_DIR
    end

    def coverage_path
      @coverage_path ||= begin
        coverage_path = File.expand_path(coverage_dir, root)
        coverage_path = File.join(coverage_path, ENV['TEST_SUITE_ID'].to_s)

        FileUtils.mkdir_p(coverage_path)

        coverage_path
      end
    end

    def coverage_track_files(glob)
      @coverage_track_files = glob
    end

    def coverage_tracked_files
      @coverage_track_files if defined?(@coverage_track_files)
    end

    def add_filter(filter = nil, &block)
      filters << parse_filter(filter, &block)
    end

    def filters
      @filters ||= []
    end

    def add_coverage_filter(filter = nil, &block)
      coverage_filters << parse_filter(filter, &block)
    end

    def coverage_filters
      @coverage_filters ||= []
    end

    def configure(&block)
      Docile.dsl_eval(self, &block)
    end

    private

    def test_suite_id
      suite_id = ENV.fetch('TEST_SUITE_ID', '')

      return if suite_id.empty?

      suite_id
    end

    def at_exit(&block)
      return Proc.new unless RSpecTracer.running || block

      @at_exit = block if block
      @at_exit ||= proc { RSpecTracer.at_exit_behavior }
    end

    def parse_filter(filter = nil, &block)
      arg = filter || block

      raise ArgumentError, 'Either a filter or a block required' if arg.nil?

      RSpecTracer::Filter.register(arg)
    end
  end
end