import type { Task } from "../types/task";
import { Text, Badge, Button } from "@fluentui/react-components"

interface TaskDetailsProps {
  task: Task | null
}

function TaskDetails(props: TaskDetailsProps) {
  let task = props.task;

  if (task == null) return <Text>"No Task Found"</Text>;

  return (
    <div key={task.id}>
      <h3>{task.title}</h3>
      <Text>{task.description}</Text>
      <Badge>{task.status}</Badge>
      <Button appearance="secondary">Edit</Button>
      <Button>Delete</Button>
    </div>
  );
}

export default TaskDetails;