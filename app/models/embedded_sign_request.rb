class EmbeddedSignRequest
    include ActiveModel::Conversion
    include ActiveModel::Validations
    extend ActiveModel::Naming
    

    attr_accessor :name, :email
    validates_presence_of :name, :message =>"Name is required"
    validates_presence_of :email, :message => "Email is required"
    validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :message => "Email is in incorrect format"

    def initialize(attributes = {})
        @email = attributes[:email]
        @name = attributes[:name]
    end

    def persisted?
        false
    end
end