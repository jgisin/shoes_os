require 'open3'

class Interface
  attr_accessor :url

  def initialize
    @url = "/Users/jgisin"
    @checked_folders = []
  end

  def get_folders(url = @url)
    Dir.chdir(url)
    file_list = Dir.glob('*').select {|f| File.directory? f }
    file_list.unshift( ".." )
  end

  def open_button(app, int, l, app_array)
    app.link l do
      if l == ".."
        int.url = int.url.split('/')[0..-2].join('/')
        list = int.get_folders(int.url)
        file_list list, int, app_array, app
      else
        int.url = int.url + "/" + l
        list = int.get_folders(int.url)
        file_list list, int, app_array, app
      end
    end
  end

  def new_folder_button(app)
    app.button "New Folder", :stroke => app.white do

    end
  end

  def file_list(list, int, app_array = nil, app)
    app_array.each { |aa| aa.clear } if app_array
    app_array = []
    container = app.stack {
      list.each_with_index do |l,index|
        app_list = app.flow {
          app.stack(:width => 0.05) {
            if l != ".."
              app.check.click do |file_check|
                if file_check.checked?
                  @checked_folders << index
                elsif !file_check.checked?
                  @checked_folders.delete(index)
                end
              end
            end
          }
          app.stack(:width => 0.4) {
            app.para "", open_button(app, int, l, app_array)
          }
        }
        app_array << app_list
      end
    }
    container.scroll_top = 0
    app_array
  end



  def render(list = get_folders)
    int = Interface.new
    Shoes.app do
      background white
      flow(:height => 29){
        background black
        int.new_folder_button self
      }
      int.file_list list, int, nil, self
    end
  end

end
int = Interface.new
int.render
