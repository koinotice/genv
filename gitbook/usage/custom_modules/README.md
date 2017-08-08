# Custom Task Modules

⚠️ ***Deprecated***, in favor of [task module plugins](../plugins/modules.md).

You can provide your own custom task modules and use them with
_Harpoon_. For a simple example, check out the `http` module's
[`handler.sh`](../../../modules/http/handler.sh) and
[`bootstrap.sh`](../../../modules/http/bootstrap.sh). Note the use of
the `## [<arg>...] %% Your description` comment convention. _Harpoon_
will use this to automatically add your custom tasks to the `help`
output.

1. Create (or symlink) a directory named `custom` in your Harpoon
   `modules` directory.
2. Create a directory for your module in `modules/custom`.
3. In your module directory:

   1. Create a file named `handler.sh`. _Harpoon_ will use this to
      handle all tasks for your module.

   2. (Optional) Create a file named `bootstrap.sh`. _Harpoon_ will use
      this to load any custom environment variables you'd like to set
      and share with other modules.

This service can now be managed with `harpoon mariadb:*`. Try `harpoon
mariadb:help` 😁

