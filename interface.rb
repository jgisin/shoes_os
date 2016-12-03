require 'fileutils'
class Interface
  attr_accessor :url, :folder_array, :checked_folders, :folder_list, :file_list, :file_array

  def initialize
    @url = "/Users/jgisin"
    @checked_folders = []
    @folder_list = []
    @file_list = []
    @folder_array = []
    @file_array = []
  end

  def get_folders(url = @url)
    Dir.chdir(url)
    @folder_list = Dir.glob('*').select {|f| File.directory? f }
    @folder_list.unshift( ".." )
  end

  def get_files(url = @url)
    Dir.chdir(url)
    @file_list = Dir.glob('*').select {|f| !File.directory? f }
  end

  def new_folder
    Dir.chdir(@url)
    Dir.mkdir("New Folder")
  end

  def delete_folder(list)
    Dir.chdir(@url)
    @checked_folders.each do |fold|
      FileUtils.rm_rf(@url + "/" + @folder_list[fold])
    end
  end

  def refresh_folders(list, int, app)
    list = int.get_folders(int.url)
    @folder_list = list
    int.folder_array = render_folder_list list, int, app
  end

  def refresh_files(list, int, app)
    list = int.get_files(int.url)
    @file_list = list
    int.file_array = render_file_list list, int, app
  end

  def open_button(app, int, l, list)
    int.checked_folders = []
    app.link l do
      if l == ".."
        int.url = int.url.split('/')[0..-2].join('/')
        refresh_folders(list, int, app)
        refresh_files(get_files, int, app)
      else
        int.url = int.url + "/" + l
        refresh_folders(list, int, app)
        refresh_files(get_files, int, app)
      end
    end
  end

  def new_folder_button(list, int, app)
    app.button "New Folder", :stroke => app.white do
      new_folder
      refresh_folders(list, int, app)
      refresh_files(get_files, int, app)
    end
  end

  def delete_folder_button(list, int, app)
    app.button "Delete Folders", :stroke => app.white do
      delete_folder(list)
      refresh_folders(list, int, app)
      refresh_files(get_files, int, app)
    end
  end

  def refresh_folder_button(list, int, app)
    app.button "Refresh", :stroke => app.white do
      refresh_folders(list, int, app)
      refresh_files(get_files, int, app)
    end
  end

  def curr_path(app, int, list)
    app.flow {
      path = app.edit_line
      path.text = int.url
      app.button "Go" do
        int.url = path.text
        refresh_folders(list, int, app)
        refresh_files(get_files, int, app)
      end
      app.button "Browser" do
        folder = app.ask_open_folder
        int.url = folder
        refresh_folders(list, int, app)
        refresh_files(get_files, int, app)
      end
    }
  end

  def folder(app, int, l, index, list)
    app.flow {
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
  end

  def file(app, l)
    app.flow {
      app.stack(:width => 0.05) {
      }
      app.stack(:width => 0.4) {
        app.para l
      }
    }
  end

  def render_folder_list(list, int, app)
    int.folder_array.each { |aa| aa.clear } if int.folder_array
    int.folder_array = []
    int.folder_array << curr_path(app, int, list)
    container = app.stack {
      list.each_with_index do |l,index|
        int.folder_array << folder(app, int, l, index, list)
      end
    }
    container.scroll_top = 0
    int.folder_array
  end


  def render_file_list(list, int, app)
    int.file_array.each { |aa| aa.clear } if int.file_array
    int.file_array = []
    container = app.stack {
      list.each_with_index do |l,index|
        int.file_array << file(app, l)
      end
    }
    int.file_array
  end

  def render(folder_list = get_folders, file_list = get_files)
    int = Interface.new
    Shoes.app do
      background white
      flow(:height => 29){
        background black
        int.new_folder_button folder_list, int, self
        int.delete_folder_button folder_list, int, self
        int.refresh_folder_button folder_list, int, self
      }
      int.folder_array = int.render_folder_list folder_list, int, self
      int.file_array = int.render_file_list file_list, int, self
    end
  end

end
int = Interface.new
int.render
