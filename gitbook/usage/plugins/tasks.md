# Task Plugins

You can provide your own custom tasks and use them with _Harpoon_. For a
simple example, check out the `http` task's
[`handler.sh`](../../../tasks/http/handler.sh) and
[`bootstrap.sh`](../../../tasks/http/bootstrap.sh). Note the use of the
`## [<arg>...] %% Your description` comment convention. _Harpoon_ will
use this to automatically add your custom tasks to the `help` output.

1. Create directory for your _task_ project, or add to an existing
   project.
2. Inside your project directory, create a directory named
   `harpoon-plugin`.
3. In the `harpoon-plugin` directory:

   1. Create a file named `handler.sh`. _Harpoon_ will use this to
      handle all commands/sub-commands for your task.

   2. (Optional) Create a file named `bootstrap.sh`. _Harpoon_ will use
      this to load any custom environment variables you'd like to set
      and share with other tasks.

   3. Create a `Dockerfile` (or add to one that already exists) with
      metadata for _Harpoon_ to use during installation.

      ```dockerfile
      FROM scratch
      
      COPY harpoon-plugin /harpoon-plugin
      
      LABEL harpoon_name=mytask
      LABEL harpoon_type=task
      LABEL harpoon_dir=/harpoon-plugin
      ```

   4. Build, tag, and push your plugin to any Docker registry.

      ```bash
      docker build -t mytask .
      docker tag mariadb <your registry>/mytask
      docker push <your registry>/mytask
      ```

4. Install your plugin

   ```bash
   harpoon plug:in <your repository>/mytask
   ```

This task's commands can now be run with `harpoon mytask:*`. Try
`harpoon mytask:help` 😁
