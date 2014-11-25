require 'sinatra'
require 'mongoid'
require 'carrierwave'
require 'carrierwave/mongoid'

configure do
  Mongoid.load!("./mongoid.yml")
end

class ImageUploader < CarrierWave::Uploader::Base
  storage :file
end

class FSElement
	include Mongoid::Document
	belongs_to :to_folder, :class_name => 'Folder', :inverse_of => :fselements
	field :path
	field :name, type: String
	field :created
	validates_presence_of :path
	validates_presence_of :name
	validates_presence_of :created
end

class Image < FSElement
	include Mongoid::Document
	mount_uploader :image, ImageUploader, type: String
	field :alias, type: String
	field :size
	validates_presence_of :size
end

class Folder < FSElement
	include Mongoid::Document
	belongs_to :to_user, :class_name => 'User', :inverse_of => :folder
	has_many :fselements, :class_name => 'FSElement', :inverse_of => :to_folder
end

class User
	include Mongoid::Document
	has_one :folder, :class_name => 'Folder', :inverse_of => :to_user
	field :user_name, type: String
	field :password, type: String
	validates_presence_of :user_name
end
