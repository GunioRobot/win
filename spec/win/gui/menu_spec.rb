require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'win/gui/menu'

module WinGuiWindowTest

  include WinTestApp
  include Win::Gui::Window

  describe Win::Gui::Menu, ' defines a set of API functions related to menus' do
    context 'non-destructive methods' do
      before(:all)do
        @app = launch_test_app
        @menu_handle = get_menu(@app.handle)
        @file_menu_handle = get_sub_menu(@menu_handle, 0)
      end
      after(:all){ close_test_app if @launched_test_app }

      describe "#get_menu" do

        spec{ use{ menu = GetMenu(@app.handle) }}
        spec{ use{ menu = get_menu(@app.handle) }}

        it "retrieves a handle to the menu assigned to the specified top-level window" do
          menu1 = GetMenu(@app.handle)
          menu2 = get_menu(@app.handle)
          menu1.should be_an Integer
          menu1.should == @menu_handle
          menu1.should == menu2
        end

        it "returns 0/nil if no menu assigned to the specified top-level window" do
          test_app_with_dialog(:close) do |app, dialog|
            GetMenu(dialog).should == 0
            get_menu(dialog).should == nil
          end
        end
      end # describe get_menu

      describe "#get_system_menu" do
        spec{ use{ system_menu = GetSystemMenu(any_handle, reset=0) }}
        spec{ use{ system_menu = get_system_menu(any_handle, reset=false) }}

        it "with reset=0/false(default) allows the application to access the window menu (AKA system menu)" do
          menu1 = GetSystemMenu(@app.handle, reset=0)
          menu2 = get_system_menu(@app.handle, reset=0)
          menu3 = get_system_menu(@app.handle)
          menu1.should be_an Integer
          menu1.should == menu2
          menu1.should == menu3
        end

        it "with reset=1/true allows the application to reset its window menu to default, returns 0/nil" do
          GetSystemMenu(@app.handle, reset=1).should == 0
          get_system_menu(@app.handle, reset=true).should == nil
        end
      end # describe get_system_menu

      describe "#get_menu_item_count" do

        spec{ use{ num_items = GetMenuItemCount(@menu_handle) }}
        spec{ use{ num_items = get_menu_item_count(@menu_handle) }}

        it "determines the number of items in the specified menu. " do
          GetMenuItemCount(@menu_handle).should == 3
          get_menu_item_count(@menu_handle).should == 3
        end

        it "returns -1/nil if function fails " do
          GetMenuItemCount(not_a_handle).should == -1
          get_menu_item_count(not_a_handle).should == nil
        end
      end # describe get_menu_item_count

      describe "#get_menu_item_id" do
        spec{ use{ item_id = GetMenuItemID(@menu_handle, pos=0) }}
        spec{ use{ item_id = get_menu_item_id(@menu_handle, pos=0) }}

        it "retrieves the menu item identifier of a menu item located at the specified position" do
          GetMenuItemID(@file_menu_handle, pos=0).should == ID_FILE_SAVE_AS
          get_menu_item_id(@file_menu_handle, pos=0).should == ID_FILE_SAVE_AS
        end

        it "returns -1/nil if no menu item at given position" do
          GetMenuItemID(@menu_handle, pos=4).should == -1
          get_menu_item_id(@menu_handle, pos=4).should == nil
        end

        it "returns -1/nil if given menu item is in fact a sub-menu" do
          GetMenuItemID(@menu_handle, pos=0).should == -1
          get_menu_item_id(@menu_handle, pos=1).should == nil
        end
      end # describe get_menu_item_id

      describe "#get_sub_menu" do
        spec{ use{ sub_menu = GetSubMenu(@menu_handle, pos=0) }}
        spec{ use{ sub_menu = get_sub_menu(@menu_handle, pos=0) }}

        it "retrieves a handle to the drop-down menu or submenu activated by the specified menu item" do
          sub_menu1 = GetSubMenu(@menu_handle, pos=0)
          sub_menu2 = get_sub_menu(@menu_handle, pos=0)
          sub_menu1.should be_an Integer
          sub_menu1.should == @file_menu_handle
          sub_menu1.should == sub_menu2
        end
      end # describe get_sub_menu

      describe "#is_menu" do
        before(:all){ @menu_handle = get_menu(@app.handle) }

        spec{ use{ success = IsMenu(@menu_handle) }}
        spec{ use{ success = menu?(@menu_handle) }}

        it "determines whether a given handle is a menu handle " do
          IsMenu(@menu_handle).should == 1
          is_menu(@menu_handle).should == true
          menu?(@menu_handle).should == true
          menu?(@file_menu_handle).should == true
          IsMenu(not_a_handle).should == 0
          is_menu(not_a_handle).should == false
          menu?(not_a_handle).should == false
        end
      end # describe is_menu

      describe "#set_menu" do
        spec{ use{ success = SetMenu(window_handle=0, menu_handle=0) }}
        spec{ use{ success = set_menu(window_handle=0, menu_handle=0) }}

        it "assigns/removes menu of the specified top-level window" do
          SetMenu(@app.handle, menu_handle=0)
          get_menu(@app.handle).should == nil
          SetMenu(@app.handle, @menu_handle)
          menu(@app.handle).should == @menu_handle
          set_menu(@app.handle)
          menu(@app.handle).should == nil
          set_menu(@app.handle, @menu_handle)
          menu(@app.handle).should == @menu_handle
        end

        it "snake_case api with nil, zero or omitted menu_handle removes menu" do
          [[@app.handle, 0], [@app.handle, nil], [@app.handle]].each do |args|
            set_menu(*args)
            menu(@app.handle).should == nil
            set_menu(@app.handle, @menu_handle)
          end
        end
      end # describe set_menu

      describe "#append_menu" do
        before(:each){ @new_menu_handle = create_menu() }
        after(:each){ destroy_menu(@new_menu_handle) }

        spec{ use{ success = AppendMenu(menu_handle=0, flags=0, id_new_item=0, lp_new_item=nil) }}
        spec{ use{ success = append_menu(menu_handle=0, flags=0, id_new_item=0, lp_new_item=nil) }}

        it "appends a new item to the end of the specified menu bar, drop-down or context menu, returns 1/true " do
          text = FFI::MemoryPointer.from_string("Menu Item Text")
          append_menu(@new_menu_handle, flags=MF_STRING, ID_FILE_SAVE_AS, text).should == true
          AppendMenu(@new_menu_handle, flags=MF_STRING, ID_FILE_SAVE_AS, text).should == 1
          menu_item_count(@new_menu_handle).should == 2
          menu_item_id(@new_menu_handle, pos=0).should == ID_FILE_SAVE_AS
        end

        it "returns 0/false if unable to appends a new item to the end of the specified menu" do
          pending
          success = append_menu(h_menu=0, u_flags=0, u_id_new_item=0, lp_new_item=0)
        end
      end # describe append_menu

      describe "#create_menu" do
        after(:each){ destroy_menu(@new_menu_handle) }

        spec{ use{ @new_menu_handle = CreateMenu() }}
        spec{ use{ @new_menu_handle = create_menu() }}

        it "original api creates a menu. The menu is initially empty, but it can be filled with menu items" do
          @new_menu_handle = CreateMenu()
          menu?(@new_menu_handle).should == true
        end

        it "snake_case api creates a menu. The menu is initially empty." do
          @new_menu_handle = create_menu()
          menu?(@new_menu_handle).should == true
        end

      end # describe create_menu
    end # context 'non-destructive methods'

    context 'destructive methods' do
      before(:each)do
        @app = launch_test_app
        @menu_handle = get_menu(@app.handle)
        @file_menu_handle = get_sub_menu(@menu_handle, 0)
      end
      after(:each){ close_test_app if @launched_test_app }

      describe "#destroy_menu" do
        spec{ use{ success = DestroyMenu(menu_handle=0) }}
        spec{ use{ success = destroy_menu(menu_handle=0) }}

        it "original api destroys the specified menu and frees any memory that the menu occupies, returns 1" do
          DestroyMenu(@menu_handle).should == 1
          menu?(@menu_handle).should == false
        end

        it "snake_case api destroys the specified menu and frees any memory that the menu occupies, returns true" do
          destroy_menu(@menu_handle).should == true
          menu?(@menu_handle).should == false
        end

        it "returns 0/false if function was not successful " do
          destroy_menu(h_menu=0).should == false
          DestroyMenu(0).should == 0
        end
      end # describe destroy_menu

    end # context 'destructive methods' do

  end # describe Win::Gui::Menu, ' defines a set of API functions related to menus'

#  describe Win::Gui::Menu, ' defines convenience/service methods on top of Windows API' do
#  end # Win::Gui::Menu, ' defines convenience/service methods on top of Windows API'
end