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

  describe "status" do
    it "default status" do
      task = build(:task)
      expect(task.status).to eq('pending')
      expect(task.pending?).to eq(true)
      expect(task.completed?).to eq(false)
    end

    it "status assignment" do
      task = build(:task, status: :in_progress)
      expect(task.status).to eq('in_progress')
      expect(task.in_progress?).to eq(true)
      expect(task.pending?).to eq(false)
    end

    it "status bang methods" do
      task = build(:task)
      task.completed!
      expect(task.status).to eq('completed')
      expect(task.completed?).to eq(true)
      expect(task.pending?).to eq(false)
      task.reload # confirm db persistence
      expect(task.completed?).to eq(true)
    end

    it "Enum mapping" do
      status = described_class.statuses
      expect(status['pending']).to eq(0)
      expect(status['in_progress']).to eq(1)
      expect(status['completed']).to eq(2)
    end

    it "Invalid status" do
      task = build(:task)
      task.status = :invalid
      expect(task.valid?).to eq(false)
      not_included_msg = "Status is not included in the list"
      expect(task.errors.full_messages).to include(not_included_msg)
      task.status = nil
      task.valid?
      expect(task.errors.full_messages).to include(not_included_msg)
    end

    it "Enum scopes" do
      task1 = create(:task)
      task2 = create(:task, status: :in_progress)
      task3 = create(:task, status: :completed)
      expect(Task.pending).to eq(Task.where(status: :pending))
      expect(Task.in_progress).to eq(Task.where(status: :in_progress))
      expect(Task.completed).to eq(Task.where(status: :completed))
    end
  end
end
