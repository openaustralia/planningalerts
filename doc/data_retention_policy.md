DATA RETENTION POLICY
=====================

This documents what data we are keeping and what we can clean out to reduce the database size and stop its current rapid
growth.
A related issue is the excessive memory usage causing some authority admin pages to crash from excessive large version
lists.

No privacy act concerns are (currently) dealt with in this doc.

Related issues:

* [Periodically delete old records and vacuum to manage PlanningAlerts database size and make versioning authorities efficient #351](https://github.com/openaustralia/infrastructure/issues/351)
* [Find or make a data retention policy for planning alerts #352](https://github.com/openaustralia/infrastructure/issues/352)
* [planningalerts RDS (pg) database has run out of space #350](https://github.com/openaustralia/infrastructure/issues/350) -
  closed, increasing DB size from 50GB to 90GB gave us some breathing space at an extra monthly cost

The Primary reason for DB growth is the combination of:

* application.rb has `  belongs_to :authority, touch: true` which means authority.update_at is updated whenever an
  application is updated
* authority.boundary is a huge field, often around 300KB with the boundary of the authority in precise detail
* The default for papertrail is to save a complete copy of the record, not just what triggered the version record;
* authority has `has_paper_trail ignore: %i[last_scraper_run_log boundary]` but this still means boundary and
  last_scraper_run_log is stored in the object record (use skip to exclude)

## Decisions made

* Only look at reducing version table size (32 out of 50 GB, ie 72%)
    * Initially do a manual remove of all the duplicates (from application touching authority table),
    * Later change the code so it doesn't create duplicate versions (move 2 fields to their own tables, remove
      `touch: true` from application -> authority relationship))
* When we split boundary and last_scraper_run_log from authority out to their own tables:
    * Keep a history of all boundary changes
    * Only keep the last 6 months of import log version history
    * Keep all version history of authorities (that has actual changes)
* Show just a page of version history on the admin authorities page with a link to the full version history for faster
  page access

## Expected Impact

* Save between 90-99% of the version table, ie 65% to 72% of the current DB size
* Noticeably reduce memory usage of the app, and in particular the admin authorities page

## Context

* We currently don't expose version information anywhere except admin application view pages, so it doesn't give value
  to our clients
* Keeping a few months of version history is useful for diagnostic purposes
* Authority.updated_at is not exposed to end users, so it doesn't matter if it's updated every time an application is
  updated or not

## Database usage

Top 10 largest tables by size:

| table_name               | total_size GB |
|--------------------------|---------------|
| versions (to be trimmed) | 36 GB         |
| email_batches            | 7.2 GB        |
| application_versions     | 3.9 GB        |
| applications             | 3.1 GB        |
| comments                 | 217 MB        |
| geocode_results          | 211 MB        |
| alerts                   | 188 MB        |
| users                    | 109 MB        |
| geocode_queries          | 77 MB         |
| authorities              | 24 MB         |

## Suggestions for future work

Consider [Shrinking storage volumes for your RDS databases and optimize your infrastructure costs](https://aws.amazon.com/blogs/database/shrink-storage-volumes-for-your-rds-databases-and-optimize-your-infrastructure-costs/)
to save USD 128.88 / year
