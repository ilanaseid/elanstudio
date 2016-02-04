class MakeNewSpreeStaffRoles < ActiveRecord::Migration
  def change
    Spree::Role.find_or_create_by(name: 'staff')

    old_admins = [
      'joel@niedfeldt.com',
      'alicia@theline.com',
      'charlie@theline.com',
      'kate@theline.com',
      'baileyfoote@mac.com',
      'cnizar@gmail.com',
      'christina@theline.com',
      'elissaross@gmail.com'
    ]

    old_admins.each do |email|
      if user = Spree::User.find_by(email: email)
        user.spree_roles.clear
        user.save!
      end
    end

    current_employees = [
      'ilana@elanstudio.com',
      'adam@theline.com',
      'sarah@theline.com',
      'melanie@theline.com',
      'chris@theline.com',
      'colleen@theline.com',
      'marta@theline.com',
      'jacob@theline.com',
      'hanna@theline.com',
      'elizabeth@theline.com',
      'arielle@theline.com',
      'hello@theline.com',
      'ccasciano@theline.com',
      'dylan@theline.com',
      'ashley@theline.com',
      'kyra@theline.com',
      'pam@theline.com',
      'kendra@theline.com',
      'allee@theline.com',
      'stephen@theline.com',
      'ilana@theline.com',
      'eddie@theline.com',
      'rebecca@theline.com',
      'marko@theline.com',
      'room1015@me.com',
      'stephanie.murg@gmail.com',
      'chris@placenamehere.com',
      'bookoven@gmail.com',
      'taylerjthompson@gmail.com',
      'mike@assembledbrands.com',
      'adam@assembledbrands.com',
      'international@theline.com',
      'operations@theline.com'
    ]

    current_employees.each do |email|
      if user = Spree::User.find_by(email: email)
        staff_role = Spree::Role.find_by(name: 'staff')
        user.spree_roles << staff_role if !user.spree_roles.include?(staff_role)
        user.save!
      end
    end

    miscategorized_retail = [
      'eddie@theline.com',
      'ilana@theline.com',
      'elizabeth@theline.com',
      'jacob@theline.com',
      'room1015@me.com',
      'pam@theline.com',
      'arielle@theline.com',
      'taylerjthompson@gmail.com'
    ]

    miscategorized_retail.each do |email|
      if user = Spree::User.find_by(email: email)
        retail_role = Spree::Role.find_by(name: 'retail')
        user.spree_roles.delete(retail_role)
        user.save!
      end
    end

    customer_service_role = Spree::Role.find_or_create_by(name: 'customer_service')
    if service_user = Spree::User.find_by(email: 'operations@theline.com')
       service_user.spree_roles << customer_service_role if !service_user.spree_roles.include?(customer_service_role)
       service_user.save!
    end

  end
end
