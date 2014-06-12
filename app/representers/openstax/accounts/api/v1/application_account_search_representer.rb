module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationAccountSearchRepresenter < AccountSearchRepresenter

          collection :application_users,
                     as: :application_accounts,
                     class: OpenStax::Accounts::ApplicationAccount,
                     decorator: ApplicationAccountRepresenter,
                     schema_info: {
                       description: "The matching accounts that have used this app",
                       minItems: 0
                     }

        end
      end
    end
  end
end
