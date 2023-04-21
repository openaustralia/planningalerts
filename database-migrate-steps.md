# Steps for doing the database migration from MySQL to Postgres

These instructions are based on the current production mysql running in the blue environment
(web1.blue.planningalerts.org.au and web2.blue.planningalerts.org.au) and the postgres branch
being already deployed to the green environment (web1.green.planningalerts.org.au and
web2.green.planningalerts.org.au)

## Preparations
1. Go to the AWS console and take a snapshot of the mysql database

## Doing the actual migration
1. Disable workers on mysql:
  * Switch to master branch
  * Comment out worker in Procfile.production
  * Deploy
  * Log in to each server (web1.blue and web2.blue) and check that workers are stopped
  * Confirm from admin console of app that workers are stopped
2. Switch on "maintenance_mode" feature flag for everyone
3. Switch over to mysql readonly:
  * Switch to master branch
  * Update `config/database.yml` to use read-only config
  * Deploy
  * Check normal browsing of the site still works
4. Create the postgres schema and migrate data:
  * ssh into one of the green servers
  * `RAILS_ENV=production bin/rails runner database_migrate_template.rb`
  * `RAILS_ENV=production bin/rails db:schema:load`
  * `pgloader --verbose database-migrate-commands.production`
  * If migration fails run last TWO steps again. It's vital that db:schema:load
    gets run again otherwise it's possible for some of the foreign key constraints
    not to be set up properly.
5. Test green setup by browsing around the site and comparing it to the live production
6. Go to the AWS console and switch over all the traffic to the green environment
7. Switch from postgres readonly to read/write:
  * Switch to postgres branch
  * Update `config/database.yml` to use read/write config
  * Deploy
  * Check site is still working
7. Disable "maintenance_mode" feature flag for everyone
8. Start workers on postgres:
  * Edit `Procfile.production` on postgres branch and uncomment worker line
  * Deploy
  * Confirm from admin console of app that workers are running

## Clean up

1. Disable blue environment in terraform and run `terraform apply`
2. Change parameters on database:
  * Switch parameter_group_name for new database to the default
  * remove md5 parameter group
  * `terraform apply`
3. Merge postgres branch into master
4. Edit `config/deploy/production.rb` to deploy from master
5. Edit `config/deploy.rb` to deploy to blue and green again
6. Deploy
7. Double check that the expected version is running in production by looking at the about page
