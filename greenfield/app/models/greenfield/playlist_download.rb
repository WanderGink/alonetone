module Greenfield
  class PlaylistDownload < ActiveRecord::Base
    include Paperclip

    MAX_SIZE     = 2000.megabytes
    CONTENT_TYPE = ['application/zip', 'application/gzip']

    belongs_to :playlist


    # see config/initializers/paperclip for defaults
    attachment_options = {}
    if Alonetone.storage == 's3'
      attachment_options[:path] = ":s3_path"
      attachment_options[:s3_permissions] = 'authenticated-read' # don't want these facing the public
    end

    has_attached_file :attachment, attachment_options
    validates_attachment_presence :attachment, message: 'must be set. Make sure you chose a file to upload!'
    validates_attachment_content_type :attachment, content_type: CONTENT_TYPE,
      message: " was wrong. It doesn't look like you uploaded a valid zip file. Could you double check?"

    after_validation :destroy_s3_object_if_invalid, on: :create

    def url
      attachment.expiring_url
    end

    protected

    def destroy_s3_object_if_invalid
      attachment.try(:destroy) if errors.any?
    end
  end
end
