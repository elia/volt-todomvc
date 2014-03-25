require 'pp'

class MainController < ModelController
  model :local_store

  def model=(val)
    # Start with a nil reactive value.
    @model ||= ReactiveValue.new(Proc.new { nil })

    if Symbol === val || String === val
      collections = [:page, :store, :params, :controller, :local_store]
      if collections.include?(val.to_sym)
        @model.cur = self.send(val).cur
      else
        raise "#{val} is not the name of a valid model, choose from: #{collections.join(', ')}"
      end
    elsif val
      @model.cur = val.cur
    else
      raise "model can not be #{val.inspect}"
    end
  end

  def local_store
    $page.local_store
  end

  def index
    _all_checked.on :change do |change|
      p [:_all_checked, :change, change]
    end

    _todos.on :change do |todos|
      p [:_todos, :change, todos]
    end
    p _completed_count.inspect
  end

  def _show_completed?
    _completed_count.with{|c| c.cur > 0}
  end

  def clear_completed
    _todos.delete_if { |todo| todo._completed.true?.cur }
  end

  def _active_count
    # _todos.with{|todos| todos.cur.to_a.reject{|t| t[:_completed]}.size }
    _todos.count{|t| not(t._completed?.cur) }
  end

  def _completed_count
    # _todos.with{|todos| todos.cur.to_a.select{|t| t[:_completed]}.size }
    _todos.count{|t| t._completed? }
  end

  def _all_count
    _todos.with{|todos| todos.cur.size}
  end

  def add_todo
    _todos << {_title: self._new_todo.cur.to_s, _completed: false}
    self._new_todo = ''
    _todos.trigger(:change)
  end

  def remove_todo index
    _todos.delete_at index.cur
    _todos.trigger(:change)
  end

  def update_check_all
    all_checked = _todos.all?{|t| t._completed.true?.cur}.cur
    self._all_checked = all_checked
  end

  def check_all
    check_all = _all_checked.true?
    _todos.each{|t| t._completed = check_all}
    _todos.trigger(:change)
  end

  private
    # the main template contains a #template binding that shows another
    # template.  This is the path to that template.  It may change based
    # on the params._controller and params._action values.
    def main_path
      params._controller.or('main') + "/" + params._action.or('index')
    end
end
