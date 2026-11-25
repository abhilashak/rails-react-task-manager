import { Button, Text } from "@fluentui/react-components";

function AppHeader() {

  return (
    <>
      <h2>Task Manager</h2>
      <Text>Manage your tasks efficiently</Text>
      <Button appearance="primary">Add Task</Button>
    </>
  );
}

export default AppHeader;