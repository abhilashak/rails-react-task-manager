require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "validations" do
    it "a valid task" do
      task = build(:task)
      expect(task.valid?).to eq(true)
    end

    it "title presence, check nil, empty, space contents" do
      task = build(:task, title: nil)
      task.valid?
      expect(task.errors.full_messages).to include("Title can't be blank")
      task = build(:task, title: '')
      task.valid?
      expect(task.errors.full_messages).to include("Title can't be blank")
      expect(task.errors.full_messages).to include("Title is too short (minimum is 2 characters)")
      task = build(:task, title: '  ')
      task.valid?
      expect(task.errors.full_messages).to include("Title can't be blank")
    end
    
    it "title length" do
      task = build(:task, title: "my " * 40) # 120 chars
      expect(task.valid?).to eq(true)
      task = build(:task, title: "my " * 40 + "q") # 121 chars
      expect(task.valid?).to eq(false)
    end
    
    it "valid description" do
      task = build(:task, description: nil)
      expect(task.valid?).to eq(true)
      task = build(:task, description: "my" * 1000) # 2000 chars
      expect(task.valid?).to eq(true)
      task = build(:task, description: "my" * 1000 + 'm') # 2001 chars
      expect(task.valid?).to eq(false)
    end
    
    it "user association" do
      task = build(:task, user: nil)
      expect(task.valid?).to eq(false)
    end
  end
end
