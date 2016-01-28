class Ability
  include CanCan::Ability

  def initialize(user)

    can :read, WishlistItem if user.persisted?
    can :create, WishlistItem if user.persisted?
    can :destroy, WishlistItem, :user_id=>user.id

    can :submit, Brightpearl::ResetStockLevels if user.admin?

    can :manage, Reporting if user.has_spree_role?('staff')

    can :manage, Sidekiq if user.admin?
  end

end

Spree::Ability.register_ability(Ability)
