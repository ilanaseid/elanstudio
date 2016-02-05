class MakeNewSpreeStaffRoles < ActiveRecord::Migration
  def change
    Spree::Role.find_or_create_by(name: 'staff')

    old_admins = [
    ]

    old_admins.each do |email|
      if user = Spree::User.find_by(email: email)
        user.spree_roles.clear
        user.save!
      end
    end

    current_employees = [
      'ilana@elanstudio.com',
      'operations@elanstudio.com'
    ]

    current_employees.each do |email|
      if user = Spree::User.find_by(email: email)
        staff_role = Spree::Role.find_by(name: 'staff')
        user.spree_roles << staff_role if !user.spree_roles.include?(staff_role)
        user.save!
      end
    end

    miscategorized_retail = [
    ]

    miscategorized_retail.each do |email|
      if user = Spree::User.find_by(email: email)
        retail_role = Spree::Role.find_by(name: 'retail')
        user.spree_roles.delete(retail_role)
        user.save!
      end
    end

    customer_service_role = Spree::Role.find_or_create_by(name: 'customer_service')
    if service_user = Spree::User.find_by(email: 'operations@elanstudio.com')
       service_user.spree_roles << customer_service_role if !service_user.spree_roles.include?(customer_service_role)
       service_user.save!
    end

  end
end
