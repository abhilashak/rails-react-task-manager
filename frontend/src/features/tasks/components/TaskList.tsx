import type { Task } from "../types/task"
import { Text, Badge } from "@fluentui/react-components";

interface TaskListProps {
  tasks: Task[],
  selectedTaskId: number
}

function TaskList(props: TaskListProps) {

  return (
    <div className="task-list">
      {props.tasks.map((task) => (
        <div key={task.id} className={`task-list-item ${task.id === props.selectedTaskId
          ? 'task-list-item--selected'
          : ''
          }`}>
          <h3>{task.title}</h3>
          <div className="task-list-item__meta">
            <p>{task.description}</p>
            <Badge appearance="filled">{task.status}</Badge>
          </div>
        </div>
      ))
      }
    </div>
  );
}

export default TaskList;
