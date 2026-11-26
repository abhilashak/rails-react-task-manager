import type { Task } from "../types/task"
import { Text, Badge } from "@fluentui/react-components";

interface TaskListProps {
  tasks: Task[],
  selectedTaskId: number
}

function TaskList(props: TaskListProps) {

  return (
    <div>{props.tasks.map((task) => (
      <div key={task.id} className={props.selectedTaskId == task.id ? 'selected-task' : ''}>
        <h3>{task.title}</h3>
        <Text>{task.description}</Text>
        <Badge>{task.status}</Badge>
      </div>
    ))
    }
    </div>
  );
}

export default TaskList;
