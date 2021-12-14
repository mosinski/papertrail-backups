Simple heroku app with a bash script for make a backup of Papertrail logs into your FTP server.   
Deploy this as a separate app within heroku and schedule the script to backup your production logs.

## Installation

First create a project on heroku with the [heroku-buildpack-multi](https://github.com/heroku/heroku-buildpack-multi).

```
heroku create my-logs-backups --buildpack https://github.com/heroku/heroku-buildpack-multi
```

Next push this project to your heroku projects git repository.

```
git remote add heroku git@heroku.com:my-logs-backups.git
git push heroku master
```

Now we need to set some environment variables

```
heroku config:add FTP_HOST=example.com -a my-logs-backups
heroku config:add FTP_USER=test@test.com -a my-logs-backups
heroku config:add FTP_PASSWORD=password -a my-logs-backups
heroku config:add FTP_DIRECTORY=path -a my-logs-backups
heroku config:add HTTP_API_KEY=papertrail_api_key -a my-logs-backups
```

Optional to set logs grouping format:

```
heroku config:add LOGS_FORMAT=logs_format -a my-logs-backups
```

*Possible values*:

**Day**: `%Y-%m-%d`   
**Month**: `%Y-%m`   
**Year**: `%Y`   
*Default* **Hours**: `%Y-%m-%d-%H`


Finally, we need to add heroku scheduler and call [backup.sh](https://github.com/mosinski/papertrail-backups/blob/master/bin/backup.sh).

```
heroku addons:create scheduler -a my-logs-backups
```

Now open it up, in your browser with:

```
heroku addons:open scheduler -a my-logs-backups
```

And add the following command to run at every hour:

```
/app/bin/backup.sh
```
