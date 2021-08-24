# frozen_string_literal: true

Given('I am working on the project {string}') do |project|
  @project = project
  @cache_dir = 'rspec_tracer_cache'
  @coverage_dir = 'rspec_tracer_coverage'
  @data_dir = "data/#{@project}"
  @run_id = case @project
            when 'rails_app'
              '6654a84c672a717904112cef7503d7a1'
            when 'ruby_app'
              '35fdbfe849971451ec5d06879de976d5'
            end

  project_dir = File.dirname(__FILE__)

  cd('.') do
    FileUtils.rm_rf('project')

    FileUtils.rm_rf(File.join(project_dir, '../../sample_projects/coverage'))
    FileUtils.rm_rf(File.join(project_dir, '../../sample_projects/rspec_tracer'))

    FileUtils.cp_r(
      File.join(project_dir, "../../sample_projects/#{project}/"),
      'project'
    )
  end
end

Given('I use {string} as spec helper') do |spec_helper|
  project_dir = File.dirname(__FILE__)

  cd('.') do
    FileUtils.cp(
      File.join(project_dir, "../../sample_projects/spec_helpers/#{@project}/#{spec_helper}"),
      'project/spec/spec_helper.rb'
    )
  end

  steps %(
    When I cd to "project"
  )
end

Given('I replace spec helper with {string}') do |spec_helper|
  project_dir = File.dirname(__FILE__)

  cd('.') do
    FileUtils.cp(
      File.join(project_dir, "../../sample_projects/spec_helpers/#{@project}/#{spec_helper}"),
      'spec/spec_helper.rb'
    )
  end
end

Given('I want to explicitly run all the tests') do
  set_environment_variable('RSPEC_TRACER_NO_SKIP', 'true')
end

Given('I reset explicit run') do
  delete_environment_variable('RSPEC_TRACER_NO_SKIP')
end

Given('I use test suite id {int}') do |suite_id|
  @suite_id = suite_id
  @cache_dir = "rspec_tracer_cache/#{@suite_id}"
  @coverage_dir = "rspec_tracer_coverage/#{@suite_id}"
  @data_dir = "data/#{@project}/#{@suite_id}"
  @run_id = case [@project, @suite_id]
            when ['ruby_app', 1]
              '9badef37e6a3dd45e4d0342956371b73'
            when ['rails_app', 1]
              'cf7e97dcafe77149bac34e2f6f35ff38'
            when ['ruby_app', 2], ['rails_app', 2]
              'aa2c6f193206bf829ea3cb17f5c7672e'
            end

  set_environment_variable('TEST_SUITE_ID', suite_id)
end

Given('I reset test suite id') do
  @suite_id = nil
  @cache_dir = 'rspec_tracer_cache'
  @coverage_dir = 'rspec_tracer_coverage'
  @data_dir = "data/#{@project}"
  @run_id = case @project
            when 'rails_app'
              '6654a84c672a717904112cef7503d7a1'
            when 'ruby_app'
              '35fdbfe849971451ec5d06879de976d5'
            end

  delete_environment_variable('TEST_SUITE_ID')
end

When('I run specs using {string}') do |command|
  steps %(
    When I successfully run `bundle install` for up to 120 seconds
    Then I validate simplecov version
    And I validate rspec or rspec rails version
    When I run `bundle exec #{command}`
  )
end

Then('I validate simplecov version') do
  cd('.') do
    expected = Gem::Dependency.new('simplecov', ENV['SIMPLECOV_VERSION'])
    actual = Gem::Dependency.new(
      'simplecov',
      `bundle show simplecov`.chomp.split('/').last.split('-').last
    )

    expect(expected =~ actual).to eq(true)
  end
end

Then('I validate rspec or rspec rails version') do
  cd('.') do
    case @project
    when 'rails_app'
      rspec_gem = 'rspec-rails'
      expected = Gem::Dependency.new(rspec_gem, ENV['RSPEC_RAILS_VERSION'])
    when 'ruby_app'
      rspec_gem = 'rspec'
      expected = Gem::Dependency.new(rspec_gem, ENV['RSPEC_VERSION'])
    end

    actual = Gem::Dependency.new(
      rspec_gem,
      `bundle show #{rspec_gem}`.chomp.split('/').last.split('-').last
    )

    expect(expected =~ actual).to eq(true)
  end
end