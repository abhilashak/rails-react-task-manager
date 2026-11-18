require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "FactoryBot associations" do
    context "build associated user" do
      it "task is not persisted and has a non-persisted user object associated with it" do
        task = build(:task)
        expect(task.persisted?).to eq(false)
        expect(task.user.is_a?(User)).to eq(true)
        expect(task.user.persisted?).to eq(false)
      end
    end

    context "create associated user" do
      it "task is persisted and has a persisted user object associated with it" do
        task = create(:task)
        expect(task.persisted?).to eq(true)
        expect(task.user.is_a?(User)).to eq(true)
        expect(task.user.persisted?).to eq(true)
        expect(task.user.id).to eq(task.user_id)
      end
    end

    context "override association" do
      it "use a separate user as an association" do
        user = build(:user)
        task = build(:task, user: user)
        expect(task.user).to equal(user)
      end
    end

    context "multiple tasks for one user" do
      it "one user and three task associations" do
        user = create(:user)
        tasks = create_list(:task, 3, user: user)
        task_ids = []
        tasks.each do |task|
          task_ids << task.id
          expect(task.user).to equal(user)
        end
        expect(user.tasks.pluck(:id)).to eql(task_ids)
      end
    end
  end
end
