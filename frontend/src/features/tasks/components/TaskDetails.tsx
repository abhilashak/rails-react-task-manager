import type { Task } from "../types/task";
import { Text, Badge, Button } from "@fluentui/react-components"

interface TaskDetailsProps {
  task: Task | null
}

function TaskDetails(props: TaskDetailsProps) {
  let task = props.task;

  if (!task) {
    return (
      <div className="task-details">
        <p>Select a task to view details.</p>
      </div>
    );
  }

  return (
    <div className="task-details">
      <h2>{task.title}</h2>

      <div className="task-details__meta">
        <p>{task.description || 'No description available.'}</p>

        <Badge appearance="filled">{task.status}</Badge>
      </div>

      <div className="task-details__actions">
        <Button appearance="secondary">Edit</Button>
        <Button appearance="secondary">Delete</Button>
      </div>
    </div>
  );
}

export default TaskDetails;