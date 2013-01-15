require 'spec_helper'
require 'active_support/concern'
require 'active_record'
require 'with_model'
require 'logger'
require 'in_scope'

#ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => ":memory:"
)

describe "with scopes on ActiveRecord model" do
  extend WithModel

  with_model(:Post) do
    table do |t|
      t.string :name
      t.boolean :runs
      t.timestamps
    end

    model do
      include InScope
      scope :physically_active, where(runs: true)

      def physically_active?
        in_scope?(self.class.physically_active)
      end
    end
  end

  context "with the scope" do
    let!(:post) { Post.create(runs: true) }

    it "returns the active post" do
      Post.physically_active.should == [post]
    end

    it "returns true that its active" do
      post.should be_physically_active
    end
  end
end