require 'thor'
require 'gtool'
require 'gtool/auth'
require 'gdata'

class Gtool
  module Provision
    class Group < Thor
      Gtool.register self, "group", "group <COMMAND>", "GData group provisioning"
      namespace :group

      class_option "debug", :type => :boolean, :default => false, :lazy_default => true, :desc => "Enable debug output", :aliases => "-d"
      class_option "noop",  :type => :boolean, :default => false, :lazy_default => true, :desc => "Enable noop mode", :aliases => "-n"

      desc "list", "List groups"
      def list
        settings = Gtool::Auth.load_auth
        connection = GData::Connection.new(settings[:domain], settings[:token], options)

        groups = GData::Provision::Group.all(connection)

        fields = [:group_id, :group_name, :email_permission, :description]

        rows = groups.map do |group|
          fields.map {|f| group.send f}
        end

        print_table rows
        say "#{rows.length} entries.", :cyan
      end

      desc "get GROUP", "Get a particular group instance"
      def get(groupname)
        settings = Gtool::Auth.load_auth
        connection = GData::Connection.new(settings[:domain], settings[:token], options)

        group = GData::Provision::Group.get(connection, groupname)

        if group.nil?
          say "Group '#{groupname}' not found!", :red
        else

          group.attributes.each do |attr|
            print "#{attr.first}: "
            puts group.send attr.first
          end
        end
      end

      desc "members GROUP", "Display members of a group"
      def members(groupname)
        settings = Gtool::Auth.load_auth
        connection = GData::Connection.new(settings[:domain], settings[:token], options)

        group = GData::Provision::Group.get(connection, groupname)

        if group.nil?
          say "Group '#{groupname}' not found!", :red
        else
          members = group.list_members

          fields = [:member_id, :member_type, :direct_member]
          rows = members.map do |member|
            fields.map {|f| member.send f}
          end

          print_table rows
        end
      end

      desc "addmember GROUP MEMBER", "Add a member to a group"
      def addmember(group, member)
        settings = Gtool::Auth.load_auth
        connection = GData::Connection.new(settings[:domain], settings[:token], options)
        group = GData::Provision::Group.get(connection, group)

        group.add_member member
      end

      def self.banner(task, namespace = true, subcommand = false)
        "#{basename} #{task.formatted_usage(self, true, subcommand)}"
      end
    end
  end
end
