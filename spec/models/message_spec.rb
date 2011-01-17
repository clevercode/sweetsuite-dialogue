require 'spec_helper'

describe Message do

  context 'associations' do
    it { should belong_to(:room) }
    it { should belong_to(:user) }
  end

end
