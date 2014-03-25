require 'pp'

class MainController < ModelController
  model $page.local_store

  def index
    p :asdf
    _all_checked.on :change do |change|
      p [:_all_checked, :change, change]
    end

    _todos.on :change do |todos|
      p [:_todos, :change, todos]
    end
  end

  def add_todo
    _todos << {_title: self._new_todo.cur.to_s, _completed: false}
    self._new_todo = ''
  end

  def remove_todo index
    _todos.delete_at index.cur
  end

  def update_check_all
    all_checked = _todos.all?{|t| t._completed.true?.cur}.cur
    self._all_checked = all_checked
  end

  def check_all
    p :check_all, _all_checked.cur
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
