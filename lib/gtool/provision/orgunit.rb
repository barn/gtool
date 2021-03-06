require 'thor'
require 'gtool'
require 'gprov'

module Gtool
  module Provision
    class OrgUnit < Thor
      Gtool::CLI.register self, "orgunit", "orgunit [COMMAND]", "GProv organizational unit provisioning"
      namespace :orgunit

      class_option "debug", :type => :boolean, :desc => "Enable debug output", :aliases => "-d"
      class_option "noop",  :type => :boolean, :desc => "Enable noop mode", :aliases => "-n"

      desc "list", "List organizational units"
      def list
        connection = Gtool::Auth.connection(options)
        orgunits = GProv::Provision::OrgUnit.all(connection)
        fields = GProv::Provision::OrgUnit.attribute_names
        field_names = GProv::Provision::OrgUnit.attribute_titles

        rows = orgunits.map do |orgunit|
          fields.map {|f| orgunit.send f}
        end

        rows.unshift field_names
        print_table rows
        say "#{rows.length - 1} entries.", :cyan
      end

      desc "get ORGUNIT", "Get an orgunit"
      def get(orgunit_name)
        connection = Gtool::Auth.connection(options)
        orgunit = GProv::Provision::OrgUnit.get(connection, orgunit_name)
        fields = GProv::Provision::OrgUnit.attribute_names
        field_names = GProv::Provision::OrgUnit.attribute_titles

        if orgunit.nil?
          say "Organizational unit '#{orgunit_name}' not found!", :red
        else
          properties = fields.map {|f| orgunit.send f}
          print_table field_names.zip(properties)
        end
      end

      def self.banner(task, namespace = true, subcommand = false)
        "#{basename} #{task.formatted_usage(self, true, subcommand)}"
      end
    end
  end
end
