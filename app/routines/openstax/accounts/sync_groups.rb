# Routine for getting group updates from the Accounts server
#
# Should be scheduled to run regularly

module OpenStax
  module Accounts

    class SyncGroups

      SYNC_ATTRIBUTES = ['name', 'is_public', 'group_members',
                         'group_owners', 'member_group_nestings',
                         'cached_supertree_group_ids', 'cached_subtree_group_ids']

      lev_routine transaction: :no_transaction

      protected

      def exec(options={})

        return if OpenStax::Accounts.configuration.enable_stubbing?

        response = OpenStax::Accounts::Api.get_application_group_updates

        app_groups = []
        app_groups_rep = OpenStax::Accounts::Api::V1::ApplicationGroupsRepresenter.new(app_groups)
        app_groups_rep.from_json(response.body)

        return if app_groups.empty?

        updated_app_groups = []
        updated_groups = app_groups.each_with_object({}) do |app_group, hash|
          openstax_uid = app_group.group.openstax_uid
          group = OpenStax::Accounts::Group.where(
            openstax_uid: openstax_uid
          ).first || app_group.group
          group.syncing = true

          next unless group.persisted? || group.save

          hash[openstax_uid] = group
        end

        app_groups.each do |app_group|
          openstax_uid = app_group.group.openstax_uid
          group = updated_groups[openstax_uid]

          next if group.nil?

          if group != app_group.group
            SYNC_ATTRIBUTES.each do |attribute|
              group.send("#{attribute}=", app_group.group.send(attribute))
            end
          end

          next unless group.save

          updated_app_groups << { group_id: openstax_uid, read_updates: app_group.unread_updates }
        end

        OpenStax::Accounts::Api.mark_group_updates_as_read(updated_app_groups)

      end

    end

  end
end
