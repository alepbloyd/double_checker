# frozen_string_literal: true

require './lib/double_checker'

RSpec.describe DoubleChecker do
  before do
    described_class.config do |c|
      c.gem_path = "#{File.expand_path('.')}/spec/fixtures/dummy_gem"
      c.repo_path = "#{File.expand_path('.')}/spec/fixtures/dummy_repo"
      c.result_path = "#{File.expand_path('.')}/spec/tmp"
    end
  end

  it 'can set configurations via .config' do
    described_class.config do |c|
      expect(c).to eq(described_class)
    end
  end

  it 'can set gem_path config' do
    expect(described_class.gem_path).to eq("#{File.expand_path('.')}/spec/fixtures/dummy_gem")
  end

  it 'can set repo_path config' do
    expect(described_class.repo_path).to eq("#{File.expand_path('.')}/spec/fixtures/dummy_repo")
  end

  it 'can set result path config' do
    expect(described_class.result_path).to eq("#{File.expand_path('.')}/spec/tmp")
  end

  it 'returns an array of folders contained in the repo root path' do
    expect(described_class.folders_in_repo('')).to include('/repo_folder_1',
                                                           '/both_folder_1')
  end

  it 'returns an array of files contained in the gem root path' do
    expect(described_class.files_in_gem('')).to include('/both_file_1.rb',
                                                        '/gem_file_1.rb')
  end

  it 'returns an array of files contained in the repo root path' do
    expect(described_class.files_in_repo('')).to include('/both_file_1.rb',
                                                         '/repo_file_1.rb')

    expect(described_class.files_in_repo('')).not_to include('/gem_file_1.rb')
  end

  it 'given a file path, returns an array of all folders in that path in both the gem and repo folders' do
    expect(described_class.folder_overlap('')).to include('/both_folder_1')

    expect(described_class.folder_overlap('')).not_to include('/gem_folder_1',
                                                              '/repo_folder_1')
  end

  it 'generates folder overlap array for non-root folders' do
    expect(described_class.folder_overlap('/both_folder_1')).to include('/both_folder_1/both_folder_2')

    expect(described_class.folder_overlap('/both_folder_1')).not_to include('/both_folder_1/gem_folder_2',
                                                                            '/both_folder_1/repo_folder_2')
  end

  it 'given a file path, returns an array of all files in that path in both the gem and repo folders' do
    expect(described_class.file_overlap('')).to include('/both_file_1.rb')

    expect(described_class.file_overlap('')).not_to include('/gem_file_1.rb',
                                                            '/repo_file_1.rb')
  end

  it 'generates file overlap array for non-root folders' do
    expect(described_class.file_overlap('/both_folder_1')).to include('/both_folder_1/both_file_2.rb')

    expect(described_class.file_overlap('/both_folder_1')).not_to include('/both_folder_1/gem_file_2.rb',
                                                                          '/both_folder_1/repo_file_2.rb')
  end
end
