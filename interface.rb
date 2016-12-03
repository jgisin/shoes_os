require 'open3'

class Interface
  attr_accessor :url

  def initialize
    @url = "/Users/jgisin"
  end

  def set_list(url = @url)
    Dir.chdir(url)
    file_list = Dir.glob('*').select {|f| File.directory? f }
    file_list.unshift( ".." )
    # Dir.entries(url)
  end

  def print_ls(list)
    int = Interface.new
    Shoes.app do
      background white

      def make_list(list, int, app_array = nil)
        app_array.each { |aa| aa.clear } if app_array
        app_array = []
        container = stack {
          list.each do |l|
            app_list = flow {
              stack(:width => 0.5) {
                para l
              }
              stack(:width => 0.2) {
                button "Open" do
                  if l == ".."
                    int.url = int.url.split('/')[0..-2].join('/')
                    list = int.set_list(int.url)
                    make_list list, int, app_array
                  else
                    int.url = int.url + "/" + l
                    list = int.set_list(int.url)
                    make_list list, int, app_array
                  end
                end
              }
            }
            app_array << app_list
          end
        }
        container.scroll_top = 0
        app_array
      end

      make_list list, int

    end
  end
end

int = Interface.new
int.print_ls(int.set_list)
