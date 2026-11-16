
RSpec.describe "Test Rspec Hooks behaviour" do
  let(:execution_log) { [] }

  let(:languages) do
    execution_log << :languages_created
    ["Ruby", "JavaScript", "Python"]
  end

  let!(:fruits) do
    execution_log << :fruits_created
    ["apple", "orange", "banana"]
  end

  before(:each) do
    execution_log << :before_hook
  end

  it "Test lazy evaluation" do
    puts "execution_log: #{execution_log}"
  end
  
  it "Access let variable and check lazy evaluation when referenced" do
    expect(languages).to include("Ruby")
    puts "execution_log: #{execution_log}"
  end
  
  it "Access let variables twice within this example and verify lazy loading" do
    expect(languages).to include("Python")
    expect(languages).not_to include("Rust")
    puts "execution_log: #{execution_log}"
  end
end