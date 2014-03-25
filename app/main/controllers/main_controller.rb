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
