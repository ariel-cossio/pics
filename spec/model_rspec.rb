require 'spec_helper'

describe User do
    it { should have_fields(:user_name, :password) }
    it { should validate_presence_of(:user_name) }
    it { should have_one(:folder) }
end

describe Image do
	it { should have_fields(:alias, :size) }
    it { should validate_presence_of(:size) }
end

describe FSElement do
	it { should have_fields(:path, :name, :crated) }
    it { should validate_presence_of(:path) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:created) }
end

describe Folder do
	it { should have_many(:fselemets)}