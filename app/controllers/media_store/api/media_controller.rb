require_dependency 'media_store/api_controller'

module MediaStore::API
	class MediaController < MediaStore::APIController
		belongs_to :list, optional: true
	end
end
