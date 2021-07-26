class CreateStatsIdColumn < ActiveRecord::Migration[4.2]
  def self.up
    execute "ALTER TABLE `stats` ADD `id` INT(11) NOT NULL"
    execute "UPDATE `stats` SET `id` = '1' WHERE `key` = 'applications_sent'"
    execute "UPDATE `stats` SET `id` = '2' WHERE `key` = 'emails_sent'"
    execute "ALTER TABLE `stats` DROP PRIMARY KEY"
    execute "ALTER TABLE `stats` ADD PRIMARY KEY (`id`)"
  end

  def self.down
    execute "ALTER TABLE `stats` DROP COLUMN `id`"
    execute "ALTER TABLE `stats` ADD PRIMARY KEY (`key`)"
  end
end
