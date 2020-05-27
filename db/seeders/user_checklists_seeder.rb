require 'yaml'
require_relative 'ancestry_ordered_seeder'

module Seeders

#--------------------------
#
# @class UserChecklistsSeeder
#
# @desc Responsibility: Seed User checklists, their items and sub-checklists from a YAML file.
#   Can also write hardcoded data out to the YAML file. (can write out and read in)
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-11-29
#
#--------------------------
  class UserChecklistsSeeder < AncestryOrderedSeeder

    YAML_FILENAME = 'user-checklists.yml'
    SEEDED_CLASS = UserChecklist


    def self.create_ordered_entry(yaml_entry, parent_ordered_entry: nil, log: nil)
      self::SEEDED_CLASS.create!(user_id: yaml_entry[:user_id],
                                 name: yaml_entry[:name],
                                 description: yaml_entry[:description],
                                 master_checklist_id: yaml_entry[:master_checklist_id],
                                 date_completed: yaml_entry[:date_completed],
                                 list_position: yaml_entry[:list_position] ? yaml_entry[:list_position] : 0,
                                 parent: parent_ordered_entry)

    rescue => error
      err_str =  "trying to #{__method__} #{yaml_entry}\n   #{error.message}"
      log.error(err_str)
      raise error, err_str
    end

  end

end
