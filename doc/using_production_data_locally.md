
# Backing up production data locally

Install postgresql client on your local machine as the docker container doesn't have it:
```shell
sudo apt get install postgresql-client
```

Get the credentials from the production machine (pa1 is a ssh alias for the first of the two PA app servers)

```shell
ssh seploy@pa1
cd /srv/www/production/current
export RAILS_ENV=production
bundle exec rails console
# RDS_HOST
Rails.application.credentials.dig(:database, :postgres, :host)
# password
Rails.application.credentials.dig(:database, :postgres, :password)
```

Establish an ssh tunnel via one of the app servers to tunnel the local 5433 port to the RDS server's 5432 port:

```shell 
RDS_HOST=host_from_above
ssh -N -L 5433:$RDS_HOST:5432 pa1
```

In a separate window: It will prompt for the password you got from `config/database.yml` expression:
```shell
time pg_dump -h localhost -U pa-production -d pa-production -p 5433 -f ,production.sql
```

It took 27.4 minutes to dump the production database (86 GB of sql) via my 500/50 internet connection; YMMV.

You may now close the ssh tunnel.

# Restoring production data locally

To restore the database on the local machine to postgres in docker. I ran this outside of the docker container:
```shell
docker compose run web bin/rake db:drop db:create
docker compose run web bin/rails dbconsole -p < ,production.sql
```

This took 49 minutes on my dev system and was CPU bound.

## Resetting passwords

You will need to reset the passwords of the users in the database as the security hash won't match.
You can do this directly using the rails console:
```shell
docker compose run web bin/rails console
User.find_by(email: 'user@example.com').update(password: 'new_password')
```

# Checking database size

```shell
$ docker compose run web bin/rake db:stats
WARN[0000] Found orphan containers ([planningalerts-web-run-c3b4c80d39c0 planningalerts-web-run-a5de032b3d75 planningalerts-web-run-3d8bc3683171 planningalerts-web-run-6b80a186e9e8 planningalerts-web-run-bd9d6aa2abfd planningalerts-web-run-c8e0c796bc12 planningalerts-web-run-c4e7aab91b60 planningalerts-web-run-62c9bf748879]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up. 
[+]  4/4t 4/44
 ✔ Container planningalerts-elasticsearch-1 Running                                                                                                                                                                                                       0.0s
 ✔ Container planningalerts-postgres-1      Running                                                                                                                                                                                                       0.0s
 ✔ Container planningalerts-redis-1         Running                                                                                                                                                                                                       0.0s
 ✔ Container planningalerts-mailcatcher-1   Running                                                                                                                                                                                                       0.0s
Container planningalerts-mailcatcher-1 Waiting 
Container planningalerts-postgres-1 Waiting 
Container planningalerts-redis-1 Waiting 
Container planningalerts-elasticsearch-1 Waiting 
Container planningalerts-mailcatcher-1 Healthy 
Container planningalerts-postgres-1 Healthy 
Container planningalerts-redis-1 Healthy 
Container planningalerts-elasticsearch-1 Healthy 
Container planningalerts-web-run-1630e281b355 Creating 
Container planningalerts-web-run-1630e281b355 Created 
Table                             Count        Size
------------------------------ -------- -----------
action_mailbox_inbound_emails       556      0.3 MB
active_admin_comments                 2      0.1 MB
active_storage_attachments          716      0.2 MB
active_storage_blobs                723      0.2 MB
active_storage_variant_records        0      0.0 MB
alerts                           293982     95.4 MB
api_keys                           4616      0.9 MB
application_redirects             21542      2.5 MB
application_versions            4596660   2266.7 MB
applications                    2745403   1840.1 MB
ar_internal_metadata                  1      0.0 MB
authorities                         342     23.9 MB
comments                          59808     48.1 MB
contact_messages                   1529      0.9 MB
daily_api_usages                  20566      2.3 MB
email_batches                  74303464   7173.2 MB
geocode_queries                  611244     69.7 MB
geocode_results                 1222488    197.6 MB
github_issues                       273      0.1 MB
reports                            4193      2.9 MB
roles                                 3      0.1 MB
schema_migrations                   216      0.1 MB
spatial_ref_sys                    8500      7.0 MB
stats                                 2      0.0 MB
users                            323922    102.9 MB
users_roles                          14      0.1 MB
versions                         365199  28524.1 MB
                               ======== ===========
TOTAL                          84585964  40359.3 MB

Status as of 2026-03-30 09:04:11 UTC
(approximate count - set EXACT_COUNT=1 to get exact)
```