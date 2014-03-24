class MainController < ModelController
  def index
    # Add code for when the index view is loaded
    _todos << {_title: 'primo todo', _completed: false}
    p _todos
  end

  def add_todo
    _todos << {_title: self._new_todo.cur.to_s, _completed: false}
    p _todos
    self._new_todo = ''
  end

  def remove_todo index
    _todos.delete_at index.cur
    p [:remove_todo, index.cur]
  end

  private
    # the main template contains a #template binding that shows another
    # template.  This is the path to that template.  It may change based
    # on the params._controller and params._action values.
    def main_path
      params._controller.or('main') + "/" + params._action.or('index')
    end
end
