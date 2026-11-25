import AppHeader from './components/layout/AppHeader';
import type { Task } from './features/tasks/types/task';
import TaskList from './features/tasks/components/TaskList';
import TaskDetails from './features/tasks/components/TaskDetails';


function App() {

  // static data for testing
  const tasks: Task[] = [
    {
      id: 1,
      title: 'Learn React Hooks',
      description: 'Understand useState and useEffect',
      status: 'in_progress',
      created_at: '2026-11-25T08:00:00Z',
      updated_at: '2026-11-25T08:00:00Z'
    },
    {
      id: 2,
      title: 'Implement JWT authentication',
      description: 'Complete React authentication flow',
      status: 'pending',
      created_at: '2026-11-25T08:00:00Z',
      updated_at: '2026-11-25T08:00:00Z'
    },
    {
      id: 3,
      title: 'Configure GitHub Actions',
      description: 'Run frontend and backend CI',
      status: 'completed',
      created_at: '2026-11-25T08:00:00Z',
      updated_at: '2026-11-25T08:00:00Z'
    }
  ];


  return (
    <div>
      <AppHeader></AppHeader>
      <TaskList tasks={tasks} selectedTaskId={1}></TaskList>
      <TaskDetails task={tasks[0]}></TaskDetails>
    </div>
  );
}

export default App;