import { Button } from "@fluentui/react-components";

function AppHeader() {

  return (
    <header className="app-header">
      <div className="app-header__content">
        <h1>Task Manager</h1>
        <p>Manage your tasks efficiently</p>
      </div>

      <Button appearance="primary">
        Add Task
      </Button>
    </header>
  );
}

export default AppHeader;