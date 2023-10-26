# frozen_string_literal: true

require './lib/double_checker'
require 'fileutils'

RSpec.describe DoubleChecker do
  before do
    described_class.config do |c|
      c.gem_path = "#{File.expand_path('.')}/spec/fixtures/gem"
      c.repo_path = "#{File.expand_path('.')}/spec/fixtures/repo"
      c.result_path = "#{File.expand_path('.')}/spec/result"
    end

    FileUtils.rm_rf("#{File.expand_path('.')}/spec/result")
  end

  it 'can set configurations via .config' do
    described_class.config do |c|
      expect(c).to eq(described_class)
    end
  end

  it 'can set gem_path config' do
    expect(described_class.gem_path).to eq("#{File.expand_path('.')}/spec/fixtures/gem")
  end

  it 'can set repo_path config' do
    expect(described_class.repo_path).to eq("#{File.expand_path('.')}/spec/fixtures/repo")
  end

  it 'can set result path config' do
    expect(described_class.result_path).to eq("#{File.expand_path('.')}/spec/result")
  end

  it 'defaults to a result line width config of 30' do
    expect(described_class.result_line_width).to eq(30)
  end
  
  it 'can use a different line width config' do
    described_class.config do |c|
      c.result_line_width = 40
    end

    expect(described_class.result_line_width).to eq(40)
  end

  it 'returns an array of folders contained in the repo root path' do
    expect(described_class.folders_in_repo('')).to include('/app',
                                                           '/repo_only_folder')

    expect(described_class.folders_in_repo('')).not_to include('/gem_only_folder')
  end

  it 'returns an array of folders contained in the gem root path' do
    expect(described_class.folders_in_gem('')).to include('/app',
                                                          '/gem_only_folder')

    expect(described_class.folders_in_gem('')).not_to include('/repo_only_folder')
  end

  it 'returns an array of files contained in the repo root path' do
    expect(described_class.files_in_repo('')).to include('/Gemfile',
                                                         '/README_repo.md')

    expect(described_class.files_in_repo('')).not_to include('/README_gem.md')
  end

  it 'returns an array of files contained in the gem root path' do
    expect(described_class.files_in_gem('')).to include('/Gemfile',
                                                        '/README_gem.md')

    expect(described_class.files_in_gem('')).not_to include('/README_repo.md')
  end

  it 'given a file path, returns an array of all folders in that path in both the gem and repo folders' do
    expect(described_class.folder_overlap('')).to include('/app')

    expect(described_class.folder_overlap('')).not_to include('/gem_only_folder',
                                                              '/repo_only_folder')
  end

  it 'generates folder overlap array for non-root folders' do
    expect(described_class.folder_overlap('/app')).to include('/app/config',
                                                              '/app/controllers',
                                                              '/app/models')
  end

  it 'given a file path, returns an array of all files in that path in both the gem and repo folders' do
    expect(described_class.file_overlap('')).to include('/Gemfile')

    expect(described_class.file_overlap('')).not_to include('/README_gem.md',
                                                            '/README_repo.md')
  end

  it 'generates file overlap array for non-root folders' do
    expect(described_class.file_overlap('/app/models')).to include('/app/models/model_both.rb')

    expect(described_class.file_overlap('/both_folder_1')).not_to include('/app/models/model_gem.rb',
                                                                          '/app/models/model_repo.rb')
  end

  it 'can generate an array of all overlap files' do
    expect(described_class.full_overlap_file_array).to include('/app/config/locales/locale_both.yml',
                                                               '/app/controllers/controller_both.rb',
                                                               '/app/models/model_both.rb',
                                                               '/Gemfile')

    expect(described_class.full_overlap_file_array).not_to include('/app/config/locales/locale_gem.yml',
                                                                   '/app/config/locales/locale_repo.yml',
                                                                   '/app/controllers/controller_gem.rb',
                                                                   '/app/controllers/controller_repo.rb',
                                                                   '/app/models/model_gem.rb',
                                                                   '/app/models/model_repo.rb',
                                                                   '/README_gem.md',
                                                                   '/README_repo.md')
  end

  it 'can write a new folder to the result path' do
    described_class.create_result_folder

    expect(Dir.exist?(described_class.result_path.to_s)).to be true
  end

  it 'creates an array consistenting of each line of a given file' do
    result = described_class.create_line_array("#{described_class.gem_path}/Gemfile")

    expect(result).to include('# Hey this is the first line (both)',
                              '# Hey this is the second line (both)',
                              '# Hey this is the third line (both)',
                              '# Hey this is the fourth line (gem)',
                              '# Hey this is the fifth line (gem)')
  end

  it 'identifies lines that are only present in the gem version of a file' do
    result = described_class.lines_only_in_gem('/Gemfile')

    expect(result).to include('# Hey this is the fourth line (gem)',
                              '# Hey this is the fifth line (gem)')

    expect(result).not_to include('# Hey this is the first line (both)',
                                  '# Hey this is the second line (both)',
                                  '# Hey this is the third line (both)',
                                  '# Hey this is the fourth line (repo)',
                                  '# Hey this is the fifth line (repo)')
  end

  it 'identifies lines that are only present in the repo version of a file' do
    result = described_class.lines_only_in_repo('/Gemfile')

    expect(result).to include('# Hey this is the fourth line (repo)',
                              '# Hey this is the fifth line (repo)')

    expect(result).not_to include('# Hey this is the first line (both)',
                                  '# Hey this is the second line (both)',
                                  '# Hey this is the third line (both)',
                                  '# Hey this is the fourth line (gem)',
                                  '# Hey this is the fifth line (gem)')
  end

  xit 'creates a comparison file showing the differences' do
  end

  xit 'ignores files included in the .double_checker_ignore file' do
    expect(described_class.full_overlap_file_array).not_to include('/ignore_me.md')
  end

  xit 'counts the number of overlap files with each file extension' do
  end
end
