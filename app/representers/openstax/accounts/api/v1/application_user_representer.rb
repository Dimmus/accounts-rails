module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationUserRepresenter < Roar::Decorator
          include Roar::Representer::JSON

          property :id, 
                   type: Integer

          property :application_id,
                   type: Integer

          property :user_id,
                   type: Integer

          property :default_contact_info_id,
                   type: Integer

        end
      end
    end
  end
end
