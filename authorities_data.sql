# Clear out the table first... I know, I know. Crude first bash
DELETE FROM authority;

INSERT INTO authority (full_name, short_name, feed_url, external, disabled, planning_email) values ("Blue Mountains City Council", "Blue Mountains", "http://localhost:4567/blue_mountains?year={year}&month={month}&day={day}", 1, 0, "council@bmcc.nsw.gov.au");
INSERT INTO authority (full_name, short_name, feed_url, external, disabled, planning_email) values ("Brisbane City Council", "Brisbane", "http://localhost:4567/brisbane?year={year}&month={month}&day={day}", 1, 0, "unknown@unknown.org");
INSERT INTO authority (full_name, short_name, feed_url, external, disabled, planning_email) values ("Gold Coast City Council", "Gold Coast", "http://localhost:4567/gold_coast?year={year}&month={month}&day={day}", 1, 0, "unknown@unknown.org");
