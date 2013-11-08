class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      cannot :manage, :all
    elsif user.admin?
      can :manage, :all
    elsif user.designer?
      can_manage_plan_related
      can_manage_product_related
    end

    private

    def can_manage_product_related
      can :manage, Category
      can :manage, Product
      can :manage, Brand
      can :manage, Manufacturer
      can :manage, Supplier
      can :manage, Sale
    end

    def can_manage_plan_related
      can :manage, Plan
      can :manage, PlanSet
      can :manage, Position
    end

    def can_manage_user_related
      can :manage, User
    end

    def can_manage_store_related
      can :manage, Store
      can :manage, Region

      can :manage, Fixture
      can :manage, Bay
      can :manage, FixtureItem
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
