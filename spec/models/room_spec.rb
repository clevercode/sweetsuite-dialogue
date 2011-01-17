require 'spec_helper'

describe Room do

  context 'associations' do
    it { should have_many(:participations)
    it { should have_many(:users).through(:participations) }
  end
end
