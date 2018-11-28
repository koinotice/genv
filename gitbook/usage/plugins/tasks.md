# Task Plugins

## "Wrapped Container" Tasks

If you'd like to run a Docker container as a _Genv_ task:

1. Add the following `LABEL`s to the `Dockerfile` for your image:

  ```dockerfile
  LABEL genv_name=mytask
  LABEL genv_type=task
  LABEL genv_args="<arg...>"
  LABEL genv_description="My task does this and that"
  ```

2. Build, tag, and push your plugin to any Docker registry.

  ```bash
  docker build -t mytask .
  docker tag mytask <repository>/mytask
  docker push <repository>/mytask
  ```

3. Install your plugin.

  ```bash
  genv plug:in <repository>/mytask
  ```

This task's commands can now be run with `genv mytask <arg...>`. Try
`genv mytask:help` 😁

## Helper Tasks

You can provide your own custom tasks and use them with _Genv_. For a
simple example, check out the `http` task's
[`handler.sh`](../../../tasks/http/handler.sh) and
[`bootstrap.sh`](../../../tasks/http/bootstrap.sh). Note the use of the
`## [<arg>...] %% Your description` comment convention. _Genv_ will
use this to automatically add your custom tasks to the `help` output.

1. Create directory for your _task_ project, or add to an existing
   project.
2. Inside your project directory, create a directory named
   `genv-plugin`.
3. In the `genv-plugin` directory:

   1. Create a file named `handler.sh`. _Genv_ will use this to
      handle all commands/sub-commands for your task.

   2. (Optional) Create a file named `bootstrap.sh`. _Genv_ will use
      this to load any custom environment variables you'd like to set
      and share with other tasks.

   3. Create a `Dockerfile` (or add to one that already exists) with
      metadata for _Genv_ to use during installation.

      ```dockerfile
      FROM scratch
      
      COPY genv-plugin /genv-plugin
      
      LABEL genv_name=mytask
      LABEL genv_type=task
      LABEL genv_dir=/genv-plugin
      ```

   4. Build, tag, and push your plugin to any Docker registry.

      ```bash
      docker build -t mytask .
      docker tag mytask <repository>/mytask
      docker push <repository>/mytask
      ```

4. Install your plugin.

   ```bash
   genv plug:in <repository>/mytask
   ```

This task's commands can now be run with `genv mytask:*`. Try
`genv mytask:help` 😁
