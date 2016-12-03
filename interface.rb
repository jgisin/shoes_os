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

  def open_file(filename)
    system("open #{filename}")
  end

  def new_folder
    Dir.chdir(@url)
    Dir.mkdir("New Folder")
  end

  def delete_folder
    Dir.chdir(@url)
    @checked_folders.each do |fold|
      FileUtils.rm_rf(@url + "/" + @folder_list[fold])
    end
  end

  def refresh_folders(list, int, app)
    list = int.get_folders(int.url)
    @folder_list = list
    int.folder_array = render_folder_list int, app
  end

  def refresh_files(list, int, app)
    list = int.get_files(int.url)
    @file_list = list
    int.file_array = render_file_list int, app
  end

  def refresh(int, app)
    refresh_folders(get_folders, int, app)
    refresh_files(get_files, int, app)
  end

  def open_button(app, int, l)
    int.checked_folders = []
    app.link l do
      if l == ".."
        int.url = int.url.split('/')[0..-2].join('/')
        refresh(int, app)
      else
        int.url = int.url + "/" + l
        refresh(int, app)
      end
    end
  end

  def new_folder_button(int, app)
    app.button "New Folder", :stroke => app.white do
      new_folder
      refresh(int, app)
    end
  end

  def delete_folder_button(int, app)
    app.button "Delete Folders", :stroke => app.white do
      delete_folder
      refresh(int, app)
    end
  end

  def refresh_folder_button(int, app)
    app.button "Refresh", :stroke => app.white do
      refresh(int, app)
    end
  end

  def curr_path(app, int)
    app.flow {
      app.background app.silver
      path = app.edit_line(:margin_left => 10, :margin_top => 10)
      path.text = int.url
      app.button("Go", :margin_top => 10) do
        int.url = path.text
        refresh(int, app)
      end
      app.button("Browser", :margin_top => 10) do
        folder = app.ask_open_folder
        unless folder.nil?
          int.url = folder
          refresh(int, app)
        end
      end
    }
  end

  def folder(app, int, l, index)
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
        app.para "", open_button(app, int, l)
      }
    }
  end

  def open_file_link(app, l)
    app.link(l, :stroke => app.red) do
      open_file(l)
    end
  end

  def file(app, l)
    app.flow {
      app.stack(:width => 0.05) {
      }
      app.stack(:width => 0.4) {
        app.para("", open_file_link(app, l))
      }
    }
  end

  def render_folder_list(int, app)
    int.folder_array.each { |aa| aa.remove } if int.folder_array
    int.folder_array = []
    int.folder_array << curr_path(app, int)
    container = app.stack {
      get_folders.each_with_index do |l,index|
        int.folder_array << folder(app, int, l, index)
      end
    }
    container.scroll_top = 0
    int.folder_array
  end


  def render_file_list(int, app)
    int.file_array.each { |aa| aa.remove } if int.file_array
    int.file_array = []
    app.stack {
      get_files.each_with_index do |l,index|
        int.file_array << file(app, l)
      end
    }
    int.file_array
  end

  def render
    int = Interface.new
    Shoes.app do
      background white
      flow(:height => 29){
        background black
        int.new_folder_button int, self
        int.delete_folder_button int, self
        int.refresh_folder_button int, self
      }
      int.folder_array = int.render_folder_list int, self
      int.file_array = int.render_file_list int, self
    end
  end

end
int = Interface.new
int.render
