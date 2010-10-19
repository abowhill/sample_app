require 'spec_helper'

describe User do

  # prior to each test, re-assign uname and address to hash 
  # this hash stores User object attributes

  before(:each) do
    @attr = { :name => "Example User", :email => "user@example.com" }
  end

  # Smoke test: check that we can simply create the user with the attribs
  # Not committed to db

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  # test mmodel validator function that requires name field to be defined

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

# verify behavior of model's email address validator
  
  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
 
 # test model's character length limit validator for email 

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

# test model's e-mail address format validator: happy path

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

# test model's e-mail address format validator on a few unhappy paths

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

# test model's email uniqueness validator against simple duplication attempt

  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

# test model's email uniquess validator for duplication via upper-lower case comparison

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
end
