require 'open3'

class Interface
  attr_accessor :url, :file_array, :checked_folders

  def initialize
    @url = "/Users/jgisin"
    @checked_folders = []
    @file_array = []
  end

  def get_folders(url = @url)
    Dir.chdir(url)
    file_list = Dir.glob('*').select {|f| File.directory? f }
    file_list.unshift( ".." )
  end

  def new_folder
    Dir.chdir(@url)
    Dir.mkdir(File.join(Dir.home, "New Folder"), 0700)
  end

  def delete_folder(list)
    Dir.chdir(@url)
    @checked_folders.each do |fold|
      Dir.delete(list[fold])
    end
  end

  def refresh_folders(list, int, app)
    list = int.get_folders(int.url)
    int.file_array = file_list list, int, int.file_array, app
  end

  def open_button(app, int, l, list)
    app.link l do
      if l == ".."
        int.url = int.url.split('/')[0..-2].join('/')
        refresh_folders(list, int, app)
      else
        int.url = int.url + "/" + l
        refresh_folders(list, int, app)
      end
    end
  end

  def new_folder_button(list, int, app)
    app.button "New Folder", :stroke => app.white do
      new_folder
      refresh_folders(list, int, app)
    end
  end

  def delete_folder_button(list, int, app)
    app.button "Delete Folders", :stroke => app.white do
      delete_folder(list)
      refresh_folders(list, int, app)
    end
  end

  def refresh_folder_button(list, int, app)
    app.button "Refresh", :stroke => app.white do
      refresh_folders(list, int, app)
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
            app.para "", open_button(app, int, l, list)
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
        int.new_folder_button list, int, self
        int.delete_folder_button list, int, self
        int.refresh_folder_button list, int, self
      }
      int.file_array = int.file_list list, int, nil, self
    end
  end

end
int = Interface.new
int.render
