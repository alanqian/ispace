class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validate :username, uniqueness: true
  validate :employee_id, uniqueness: true

  belongs_to :store

  def admin?
    self.role == 'admin'
  end

  def designer?
    self.role == 'designer'
  end

  def sale?
    self.role == 'sale'
  end

  def store_name
    self.store.try(:name)
  end
end
