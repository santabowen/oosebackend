class User < ActiveRecord::Base
  has_many :activities, dependent: :destroy
	attr_accessor :password
	before_save { self.email  = email.downcase }
  before_save { self.gender = gender.downcase }
	before_save :encrypt_password
	validates :name, presence: true, length: { maximum: 50 } 
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 
	validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }

  def encrypt_password
    if password.present?      
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_digest = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.authenticate(user, password)  
    if user
      if user.password_digest == BCrypt::Engine.hash_secret(password, user.password_salt)
        puts "\n~~~~~~~~~~Right Email and Password~~~~~~~~~~~~\n"
        user
      else
        puts "\n~~~~~~~~~~Wrong Password~~~~~~~~~~~~\n"
        puts ::BCrypt::Engine.hash_secret(password, user.password_salt)
      end
    else
      nil
    end
  end
end
