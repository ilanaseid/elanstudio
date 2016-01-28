class CreateMailchimpSandboxLists < ActiveRecord::Migration
  def change

    # set The Line List to Production
    if EmailList.unscoped.find_by(mailchimp_list_id: '2269eed362')
      EmailList.unscoped.find_by(mailchimp_list_id: '2269eed362').update(environment: 'production')
    end

    # set Apartment List to Production
    if EmailList.unscoped.find_by(mailchimp_list_id: '06f85ee271')
      EmailList.unscoped.find_by(mailchimp_list_id: '06f85ee271').update(environment: 'production')
    end

    # create sandbox the line list if not found
    if !EmailList.unscoped.find_by(mailchimp_list_id: 'a6ea9e3c86')
      EmailList.create(
        mailchimp_list_id: "a6ea9e3c86",
        display_name: "Sandbox The Line General List",
        short_description: "sandbox The Line general list",
        visible_to_users: true,
        mailchimp_name: "Sandbox The Line Development",
        environment: "sandbox")
    end

    # create sandbox apartment list if not found
    if !EmailList.unscoped.find_by(mailchimp_list_id: "00b95e8b14")
      EmailList.create(
        display_name: "Sandbox The Apartment Development",
        mailchimp_list_id: "00b95e8b14",
        short_description: "sandbox apartment email list",
        visible_to_users: true,
        mailchimp_name: "Sandbox Apartment List for Dev",
        environment: "sandbox")
    end

  end
end
