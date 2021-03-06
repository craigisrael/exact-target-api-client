class ExactTarget::Subscriber < ExactTarget::Base

  def create(attributes = {})
      attr = attributes.clone
      email = attr.delete(:email)
      options = attr.delete(:options) || {}
      options = options.clone
      lists = options.delete(:lists) || []
      skip_welcome = options.delete(:skip_welcome)

      mail_attributes = {}
      mail_attributes["First Name"] = attr.delete(:first_name)
      mail_attributes["Last Name"] = attr.delete(:last_name)
      mail_attributes["Zipcode"] = attr.delete(:zip_code)
      mail_attributes.merge(attr)

      send_request create_body(email, mail_attributes, lists)
      queue_triggered_send(:welcome, email) unless skip_welcome
      self
  end

  def create_body(email, attr, lists = [])
    lists << ExactTarget::Base.master_list_id unless lists.include?(ExactTarget::Base.master_list_id)
  {
        "Options" => {
          "SaveOptions" => {
            "SaveOption" => {
              "SaveAction" => "UpdateAdd",
              "PropertyName" => "*"
            }
          }
        },
        "Objects" => {
          "EmailAddress" => email,
          "Lists" => {
            "ID" => lists
          },
          "Attributes" => build_attributes(attr)
          },
          :attributes! => {
            "Objects" => {"xsi:type" => "Subscriber"}
        }
    }
  end

end
