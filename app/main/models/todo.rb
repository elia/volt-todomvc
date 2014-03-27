class Todo < Model
  def id
    @_id
  end

  def completed?
    not _completed.nil?.cur
  end

  def visible_for? filter
    (filter.nil?.or(filter == '')).or(
      _completed.true?.and(filter == 'completed')
    ).or(
      _completed.nil?.and(filter == 'active')
    )
  end
end
