require './lib/double_checker'

RSpec.describe DoubleChecker do

  before :each do
    DoubleChecker.config do |c|
      c.gem_path = "/spec/fixtures/dummy_gem"
      c.repo_path = "/spec/fixtures/dummy_repo"
      c.result_path = "spec/tmp"
    end
  end

  it 'can set configurations via .config' do
    DoubleChecker.config do |c|
      expect(c).to eq(DoubleChecker)
    end
  end

  it 'can set gem_path' do
    expect(DoubleChecker.gem_path).to eq("/spec/fixtures/dummy_gem")
  end

  it 'can set repo_path' do
    expect(DoubleChecker.repo_path).to eq("/spec/fixtures/dummy_repo")
  end

  it 'can set result path' do
    DoubleChecker.config do |c|
      c.result_path = "spec/tmp"
    end

    expect(DoubleChecker.result_path).to eq("spec/tmp")
  end

  it 'returns an array of folders contained in the gem path' do
    expect(DoubleChecker.)
  end


end