# frozen_string_literal: true

class Pawoo::SuggestionStripPropsPresenter < ActiveModelSerializers::Model
  attributes :locale, :accounts, :tags
end
