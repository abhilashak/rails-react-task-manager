class TaskBlueprint < Blueprinter::Base
  identifier :id

  fields :title, :description, :status, :created_at, :updated_at
end