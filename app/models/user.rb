class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validate :username, uniqueness: true
  validate :employee_id, uniqueness: true

  def admin?
    self.role == 'admin'
  end

  def designer?
    self.role == 'designer'
  end
end
