json.extract! training_resource, :id, :state, :document, :created_at, :updated_at
json.url training_resource_url(training_resource, format: :json)
json.document url_for(training_resource.document)
