# == Schema Information
# Schema version: 20101017194947
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'digest'

class User < ActiveRecord::Base

   attr_accessor :password
   attr_accessible :name, :email, :password, :password_confirmation

   email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

   validates :name,  :presence => true,
                     :length   => { :maximum => 50 }
   validates :email, :presence => true,
                     :format   => { :with => email_regex },
                     :uniqueness => { :case_sensitive => false }
  
   # Automatically create the virtual attribute 'password_confirmation'.
   validates :password, :presence     => true,
                        :confirmation => true,
                        :length       => { :within => 6..40 }
 
   # callback :encrypt_password on the before_save event  
   before_save :encrypt_password

   # Return true if the user's password matches the submitted password.
   # this allows us to safely test private data
   # Compare encrypted_password with the encrypted version of submitted_password.

   def has_password?(submitted_password)
     encrypted_password == encrypt(submitted_password)
   end
 
   # authenticate (class method) returns user or nil based on find of a user by 
   # e-mail and password matches
 
   def self.authenticate(email, submitted_password)
      user = find_by_email(email)
      return nil  if user.nil?
      return user if user.has_password?(submitted_password)
   end

   # PRIVATE methods and data below

   private

     # the callback
     # self is required here, as ruby would think it was a block-local variable.
     # self refers to the current user instance.
     # uses an sha2 hash, then salts it with time-date

     def encrypt_password
       self.salt = make_salt if new_record?
       self.encrypted_password = encrypt(password)
     end
   
     # called by the callback 
     def encrypt(string)
       secure_hash("#{salt}--#{string}")
     end

     def make_salt
       secure_hash("#{Time.now.utc}--#{password}")
     end
    
     def secure_hash(string)
       Digest::SHA2.hexdigest(string)
     end
end
