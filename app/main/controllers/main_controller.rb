require 'pp'

ModelController.class_eval do
  COLLECTIONS = [:page, :store, :params, :controller, :local_store]

  def model=(val)
    # Start with a nil reactive value.
    @model ||= ReactiveValue.new(Proc.new { nil })
    collections = COLLECTIONS

    if Symbol === val || String === val
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
end

class URL
  attr_reader :fragment
end

class MainController < ModelController
  model :local_store
  ESCAPE_KEY = 27

  def show_completed?
    _completed_count > 0
  end

  def _current_filter
    @_current_filter ||= ReactiveValue.new(url.fragment)
  end

  def initialize *args, &block
    super
    _current_filter.on :changed do |val|
      p [:fragment, val]
      update_filter(val.cur)
    end
  end

  def clear_completed
    self._todos.cur = _todos.reject {|t| t.completed?}.cur
  end

  def update_filter(filter)
    _current_filter.cur = filter;
    go filter.cur.to_s == '' ? '' : '#'+filter
    _todos.trigger! :changed
  end

  def _active_count
    _todos.count{|t| t._completed.nil? }
  end

  def _completed_count
    _todos.count{|t| t._completed.true? }
  end

  def _todos
    @todos ||= begin
      todos = model._todos
      if todos.nil?.cur
        todos << {_title: :temp}
        todos.delete_at(0)
      else
        todos.map!{|t| Todo.new(t.to_h)}
      end
      todos
    end
  end

  def _all_count
    _todos.with{|todos| todos.cur.size}
  end

  def add_todo
    _todos << Todo.new(_title: _new_todo.cur.to_s, _completed: false)
    self._new_todo = ''
  end

  def remove_todo todo
    _todos.delete todo
  end

  def edit(todo)
    _todos.each {|t| t._editing = false}
    page._new_title = ''
    page._editing = todo
  end

  def cancel_edit(todo)
    page._editing = nil
  end

  def save_edit(todo)
    todo._title = page._new_title
    page._editing = nil
  end

  def editing?(todo)
    page._editing == todo
  end

  def update_check_all
    all_checked = _todos.all?{|t| t._completed.true?.cur}.cur
    self._all_checked = all_checked
  end

  def check_all
    check_all = _all_checked.true?
    _todos.each{|t| t._completed = check_all}
  end

  private
    # the main template contains a #template binding that shows another
    # template.  This is the path to that template.  It may change based
    # on the params._controller and params._action values.
    def main_path
      params._controller.or('main') + "/" + params._action.or('index')
    end
end
