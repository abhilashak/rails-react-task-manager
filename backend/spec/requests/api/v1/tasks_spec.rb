
require "rails_helper"

RSpec.describe "API V1 Tasks", type: :request do
  let(:user) { create(:user) }
  let(:token) { Authentication::AccessToken.issue(user) }

  let(:headers) do
    { "Authorization" => "Bearer #{token}" }
  end

  let(:endpoint) { "/api/v1/tasks" }

  describe "GET /api/v1/tasks" do
    it "returns only the authenticated user's tasks" do
      tasks = create_list(:task, 2, user: user)
      create(:task) # Another user's task

      get endpoint, headers: headers

      expect(response).to have_http_status(:ok)

      ids = response.parsed_body["data"].pluck("id")

      expect(ids).to match_array(tasks.pluck(:id))
    end

    it "rejects requests without a JWT" do
      get endpoint

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects invalid JWT" do
      get endpoint, headers: {
        "Authorization" => "Bearer invalid-token"
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/tasks/:id" do
    it "returns an owned task" do
      task = create(:task, user: user)

      get "#{endpoint}/#{task.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("data", "id")).to eq(task.id)
    end

    it "does not expose another user's task" do
      another_user_task = create(:task)

      get "#{endpoint}/#{another_user_task.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/tasks" do
    let(:task_params) do
      {
        task: {
          title: "Learn React",
          description: "Understand React hooks",
          status: "pending"
        }
      }
    end

    it "creates a task for the authenticated user" do
      expect {
        post endpoint, params: task_params, headers: headers
      }.to change(Task, :count).by(1)

      expect(response).to have_http_status(:created)

      task = Task.find(response.parsed_body.dig("data", "id"))

      expect(task.user_id).to eq(user.id)
    end

    it "does not allow assigning another user through user_id" do
      another_user = create(:user)

      params = task_params.deep_merge(
        task: { user_id: another_user.id }
      )

      post endpoint, params: params, headers: headers

      created_task = Task.find(response.parsed_body.dig("data", "id"))

      expect(created_task.user_id).to eq(user.id)
    end

    it "returns validation errors for invalid task" do
      params = {
        task: { title: nil }
      }

      post endpoint, params: params, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "PATCH /api/v1/tasks/:id" do
    it "updates an owned task" do
      task = create(:task, user: user)

      patch "#{endpoint}/#{task.id}",
            params: { task: { title: "Updated task" } },
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(task.reload.title).to eq("Updated task")
    end

    it "cannot update another user's task" do
      task = create(:task)

      patch "#{endpoint}/#{task.id}",
            params: { task: { title: "Hacked" } },
            headers: headers

      expect(response).to have_http_status(:not_found)
      expect(task.reload.title).not_to eq("Hacked")
    end
  end

  describe "DELETE /api/v1/tasks/:id" do
    it "deletes an owned task" do
      task = create(:task, user: user)

      expect {
        delete "#{endpoint}/#{task.id}", headers: headers
      }.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "cannot delete another user's task" do
      task = create(:task)

      expect {
        delete "#{endpoint}/#{task.id}", headers: headers
      }.not_to change(Task, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
