
RSpec.describe "Test rspec lifecycle hooks" do
  let(:execution_log) { [] }
  let(:title) { "  LEARN RSPEC  " }

  subject(:normalized_title) do
    execution_log << :subject_executed
    puts "subject execution_log: #{execution_log}"
    title.downcase.strip
  end

  let(:animal) do
    execution_log << :animal
    "Lion"
  end

  let!(:bird) do
    execution_log << :bird
    "Eagle"
  end

  describe "let and let!" do
    it "test let! evaluation" do
      expect(execution_log.count(:animal)).to eq(0)
      expect(execution_log.count(:bird)).to eq(1)
      expect(execution_log.count(:subject_executed)).to eq(0)
    end
  end

  describe "test subject lazyness" do
    it "call subject and check the counter" do
      normalized_title
      subject
      expect(execution_log.count(:subject_executed)).to eq(1)
    end
  end

  before do
    p "Outer hook"
  end

  describe "Test hook ordering" do
    before do
      p "Inner hook"
    end
    it "test inner hook" do
      expect(execution_log.count(:subject_executed)).to eq(0)
      expect(execution_log.count(:animal)).to eq(0)
      expect(execution_log.count(:bird)).to eq(1)
    end
  end
end