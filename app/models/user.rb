class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :email, :name, :password
  
  validates :password, presence: true, if: "hashed_password.blank?"
  
  validates :name, presence: true,
                      length: { minimum: 4, maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                        format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
  
  has_many :micro_posts

  before_save :encrypt_password
                
  def encrypt_password
    self.salt ||= Digest::SHA256.hexdigest("--#{Time.now.to_s}- -#{email}--")
    self.hashed_password = encrypt(password)
  end
  
  def encrypt(raw_password)
    Digest::SHA256.hexdigest("--#{salt}--#{raw_password}--")
  end
  
  def self.authenticate(email, plain_text_password)
	salt = Digest::SHA256.hexdigest("--#{Time.now.to_s}- -#{email}--")
	hashed_password = Digest::SHA256.hexdigest("--#{salt}--#{plain_text_password}--")
    found_user= self.where("email = ?", email)
	if found_user.blank?
	  return nil
	else
	  found_user.each {|value|
		if value.hashed_password == value.encrypt(plain_text_password)
		  return value
		end
		return nil}
	end
  end
  
end