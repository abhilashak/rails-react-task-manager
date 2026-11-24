
class Api::V1::TasksController < Api::V1::BaseController
  before_action :set_task, only: %i[show update destroy]

  def index
    tasks = current_user.tasks.order(created_at: :desc)

    render json: TaskBlueprint.render_as_hash(
      tasks,
      root: :data
    ), status: :ok
  end

  def show
    render_task
  end

  def create
    task = current_user.tasks.new(task_params)

    if task.save
      render json: TaskBlueprint.render_as_hash(
        task,
        root: :data
      ), status: :created
    else
      render_validation_errors(task)
    end
  end

  def update
    if @task.update(task_params)
      render_task
    else
      render_validation_errors(@task)
    end
  end

  def destroy
    @task.destroy!
    head :no_content
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status)
  end

  def render_task
    render json: TaskBlueprint.render_as_hash(
      @task,
      root: :data
    ), status: :ok
  end

  def render_validation_errors(task)
    render json: {
      errors: task.errors.full_messages
    }, status: :unprocessable_content
  end
end
