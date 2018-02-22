# frozen_string_literal: true

class Pawoo::ReportTargetPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def create?
    staff?
  end
end
