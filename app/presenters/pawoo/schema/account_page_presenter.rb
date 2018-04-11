# frozen_string_literal: true

class Pawoo::Schema::AccountPagePresenter < ActiveModelSerializers::Model
  attributes :account, :statuses
end
