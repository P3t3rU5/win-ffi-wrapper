require 'win-ffi/user32/function/control/listbox'
require 'win-ffi/user32/enum/window/message/listbox_message'
require 'win-ffi/user32/enum/window/style/list_box_style'
require 'win-ffi/user32/enum/window/return/listbox_return'
require 'win-ffi/user32/enum/window/notification/listbox_notification'

using WinFFIWrapper::StringUtils

module WinFFIWrapper
  class Window
    def add_listbox(listbox)
      raise ArgumentError unless listbox.is_a?(ListBox)
      add_control(listbox)
    end

    def add_dirbox(dirbox)
      raise ArgumentError unless dirbox.is_a?(DirBox)
      add_control(dirbox)
    end
  end

  class ListBox
    include Control

    bindable :combobox,
             validate: [true, false]

    bindable :has_vertical_scroll,
             default:  true

    bindable :sorted,
             default:  true,
             validate: [true, false]

    bindable :multiple_selection,
             default:  false,
             validate: [true, false]

    bindable :selectable,
             default:  true,
             validate: [true, false]

    bindable :multi_column,
             default:  false,
             validate: [true, false]

    bindable :alignment,
             default: :left,
             validate: [:left, :center, :right]

    bindable :vertical_alignment,
             default: :top,
             validate: [:top, :center, :bottom]

    def_hooks :on_selection_changed

    def initialize(window, &block)
      @items_by_ref = {}
      @items_by_index = {}
      super(window, 'listbox', &block)
      window.on_loaded do
        @items_by_ref.each do |_, value|
          add_item(value[:name], value[:item])
        end
        @items_by_index.each do |index, item|
          insert_item(index, item)
        end
      end
    end

    def command(param)
      case param
      when User32::ListBoxNotification[:SELCHANGE]
        lbn_selchange
        'SELCHANGE'
      when User32::ListBoxNotification[:DBLCLK]
        double_clicked
        'DOUBLECLICKED'
      when User32::ListBoxNotification[:SELCANCEL]
        lbn_selcancel
        'SELCANCEL'
      when User32::ListBoxNotification[:ERRSPACE]
        lbn_errspace
        'ERRSPACE'
      when User32::ListBoxNotification[:SETFOCUS]
        set_focus
        'SETFOCUS'
      when  User32::ListBoxNotification[:KILLFOCUS]
        kill_focus
        'KILLFOCUS'
      end
    end

    def add_item(name, item)
      index = send_message(:ADDSTRING, 0, FFI::MemoryPointer.from_string((name+"\0").to_w).address)
      Dialog.error_box(Error.get_last_error, :ICONERROR) if index == User32::ListBoxReturn[:ERR]
      send_message(:SETITEMDATA, index, item.object_id)
      @items_by_ref[item.object_id] = {name: name, item: item, index: index}
    end

    def insert_item(index, item)
      index = send_message(:INSERTSTRING, index, FFI::MemoryPointer.from_string((item+"\0").to_w).address) || index
      @items_by_index[index] = item
    end

    def delete_at(index)
      send_message(:DELETESTRING, index, 0)
      @items_by_index.delete(index)
    end

    def size
      send_message(:GETCOUNT, 0, 0) ||  @items.size
    end

    def item_bounds(index)
      rc = RECT.new
      send_message(:GETITEMRECT, index, rc.pointer.address)
      rc
    end

    def [](index)
      index && (@items_by_index[index] || (
        text_size = send_message(:GETTEXTLEN, index, 0) || 0
        text = nil
        if text_size > 0
          FFI::MemoryPointer.new(:ushort, text_size + 1) do |buffer|
            send_message(:GETTEXT, index, buffer.address)
            text = buffer.read_array_of_uint16(text_size - 1).pack('U*')
          end
        end
        text
      ))
    end

    def[]=(index, text)

      delete_at(index)
      insert_item(index, text)

      self.selected_item = index if @handle && selected_item == index

    end

    def selected_item_index
      index = send_message(:GETCURSEL, 0, 0)
      index != User32::ListBoxReturn[:ERR] && index >= 0 && index || nil
    end

    def selected_item
      self[selected_item_index]
    end

    def selected_item=(index)
      if multiple_selection
        send_message(:SETSEL, 1, index)
      else
        send_message(:SETCURSEL, index, 0)
      end
      call_hooks :on_selection_changed
    end

    def unselect
      return send_message(:SETCURSEL, -1, 0) unless multiple_selection
      selected_items_indexes.each do |index|
        send_message(:SETSEL, 0, index)
      end
    end

    def reset
      send_message(:RESETCONTENT, 0, 0)
      @items_by_index.clear
      @items_by_ref.clear
    end

    def show(index)
      send_message(:SETTOPINDEX, index, 0)
    end

    def selected_items_indexes
      return [selected_item_index] unless multiple_selection
      count = send_message(:GETSELCOUNT, 0, 0)
      return [] unless count > 0
      FFI::MemoryPointer.new(:int, count) do |items|
        send_message(:GETSELITEMS, count, items.address)
        return items.read_array_of_int(count)
      end
    end

    def selected_items
      return [selected_item] unless multiple_selection
      selected_items_indexes.map do |index|
        self[index]
      end
    end

    def selected_items=(args)
      return unless multiple_selection
      raise ArgumentError, 'Invalid Indexes' unless args.all? { |x| x.is_a?(Integer) && x.between?(0, size) }
      args.each do |index|
        send_message(:SETSEL, 1, index)
      end
      call_hooks :on_selection_changed
    end

    alias_method :length, :size
    alias_method :count, :size
    alias_method :item_text, :[]
    alias_method :set_item_text, :[]=

    private
    def create_window_style
      style = [
          sorted && :SORT,
          !selectable && :NOSEL,
          multiple_selection && :MULTIPLESEL,
          multi_column && :MULTICOLUMN,
          :NOTIFY,
          # :NOINTEGRALHEIGHT
      ].select { |flag| flag }

      style.map { |v| User32::ListBoxStyle[v] }.reduce(0, &:|) | super
    end

    def create_window_style_extended
      User32::WindowStyleExtended[:CLIENTEDGE] | super
    end

    def send_message(message, wparam, lparam)
      User32.SendMessage(@handle, User32::ListBoxMessage[message], wparam, lparam) if @handle
    end

    def lbn_selchange
      # TODO
      # selection = send_message(:GETCURSEL, 0, 0)
      # item_id = send_message(:GETITEMDATA, selection, 0)
      # Dialog.message_box(has_vertical_scroll)
      # Dialog.message_box(selected_items)
    end

    def lbn_selcancel
      #TODO
    end

    def lbn_errspace
      #TODO
    end

  end

  class DirBox < ListBox
    def initialize(window, path, &block)
      super(window, &block)
      User32.DlgDirList(handle, path, @id, 0, User32::DlgDirListFlags[:DIRECTORY] | User32::DlgDirListFlags[:DIRECTORY])
    end
  end
end