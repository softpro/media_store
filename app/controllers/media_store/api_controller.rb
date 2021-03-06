require_dependency 'media_store/application_controller'

module MediaStore
	class APIController < ApplicationController
		inherit_resources

		respond_to :html, :xml, :json

		self.responder = Class.new(self.responder) do
			# This is the common behavior for formats associated with APIs, such as :xml and :json.
			def api_behavior error
				if put? or patch? then
					display resource
						.reload.decorate # TODO: remove
				else
					super
				end
			end
		end

		load_and_authorize_resource

		# Pagination
		has_scope :page, :default => 1
		has_scope :per

		# TODO: move out
		def self.inherited child
			super
			child.resource_class = nil
			child.send :initialize_resources_class_accessors!
			child.send :create_resources_url_helpers!
		end

		def load_and_authorize_resource *args
			args << args.extract_options!.merge({
				:except => :index, # see #collection
			})
			super
		end

		protected

		def belongs_to resource_name, *args
			super
			load_and_authorize_resource resource_name
			load_and_authorize_resource resources_configuration[:self][:instance_name],
			                            :through => resource_name
		end

		def resource
			get_resource_ivar || set_resource_ivar(
				super.decorate
			)
		end

		def collection
			set_collection_ivar( # TODO: memoize
				apply_scopes(
					end_of_association_chain.accessible_by(
						current_ability, action_name
					)
				).decorate
			)
		end

		private

		def resource_params
			params, options = super # in InheritedResources::BaseHelpers

			[
				ActionController::Parameters.new(params).
					permit(permitted_resource_params)
			]
		end
	end
end
