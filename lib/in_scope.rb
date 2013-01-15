require "in_scope/version"

module InScope
  extend ActiveSupport::Concern

  included do
    def in_scope?(scope)
      scope.where(id: self.id).exists?
    end
  end
end
