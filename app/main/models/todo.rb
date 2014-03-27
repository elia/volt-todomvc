class Todo < Model
  def visible_for? filter
    (filter.nil?.or(filter == '')).or(
      _completed.true?.and(filter == 'completed')
    ).or(
      _completed.nil?.and(filter == 'active')
    )
  end
end
