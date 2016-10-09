using WinFFIWrapper::StringUtils

require 'win-ffi/user32/enum/window/control/edit/edit_message'
require 'win-ffi/user32/enum/window/control/edit/edit_notification'
require 'win-ffi/user32/enum/window/control/edit/edit_style'
require 'win-ffi/user32/enum/window/control/scrollbar'
require 'win-ffi/user32/enum/window/message/set_margin_flag'

require 'win-ffi/core/struct/rect'

require 'win-ffi/user32/function/window/window'
require 'win-ffi/user32/function/interaction/keyboard'

require 'win-ffi-wrapper/window/control/base_control'

module WinFFIWrapper
  class TextBox
    include Control, WinFFI

    bindable :text,
             default: '',
             validate: String,
             coerce: ->(_, value) { value.to_w }

    bindable :multiline,
             default: false,
             validate: [true, false]

    bindable :autohscroll,
             default: false,
             validate: [true, false]

    bindable :autovscroll,
             default: false,
             validate: [true, false]

    bindable :can_edit,
             default: true,
             validate: [true, false],
             setter: ->(value) do
               set_value :can_edit, value do
                 self.read_only = !value
               end
             end

    bindable :alignment,
             default: :left

    bindable :letter_case,
             default: :normal,
             validate: [:normal, :uppercase, :lowercase, :upcase, :downcase]

    bindable :is_number,
             default: false,
             validate: [true, false]

    bindable :is_password,
             default: false,
             validate: [true, false]

    def_hooks :on_vertical_scroll, :on_horizontal_scroll

    def initialize(window, &block)
      super(window, 'edit', &block)
      # User32.EnableWindow(@handle, true)
      on_click do
        User32.SetFocus(@handle)
      end
    end

    # Can only be called on load

    def can_undo?
      !send_message(:CANUNDO).zero?
    end

    def char_from_pos(x, y)
      send_message(:CHARFROMPOS, 0, makelparam(xPos, yPos))
    end

    def empty_undo_buffer
      send_message(:EMPTYUNDOBUFFER)
    end

    def fmt_lines(add_eof = true)
      send_message(:FMTLINES, add_eof ? 1 : 0)
    end

    def get_first_visible_line
      send_message(:GETFIRSTVISIBLELINE)
    end

    def get_limit_text
      send_message(:GETLIMITTEXT)
    end

    def get_line(line)
      result = nil
      size = 254
      FFI::MemoryPointer.new(:ushort, size) do |text|
        text.write_bytes(size.to_s(16))
        len = send_message(:GETLINE, line, text.address)
        result = text.read_array_of_uint16(len).pack('U*')
      end
      result
    end

    def get_line_count
      send_message(:GETLINECOUNT)
    end

    def get_margins
      result = send_message(:GETMARGINS)
      {left: loword(result), right: hiword(result)}
    end

    def get_modify
      !send_message(:GETMODIFY).zero?
    end

    def get_password_char
      [send_message(:GETPASSWORDCHAR)].pack('U')
    end

    def get_rect
      rect = RECT.new
      send_message(:GETRECT, 0, rect.pointer.address)
      rect
    end

    def get_sel
      result = send_message(:GETSEL)
      loword(result)..hiword(result)
    end

    def get_selected_text
      text[get_sel]
    end

    # 0 : it doesn't exist
    # @return [Object]
    def get_word_break_proc
      send_message(:GETWORDBREAKPROC)
    end

    def limit_text(limit)
      send_message(:LIMITTEXT, limit)
    end

    # index = -1 : get the line from the caret position or beginning of selection
    # index = any other value : get the line from that character postition in the string
    # @param [Object] index
    # @return [Integer]
    def line_from_char(index = -1)
      send_message(:LINEFROMCHAR, index.to_i)
    end

    def line_index(line = -1)
      send_message(:LINEINDEX, line.to_i)
    end

    # index = -1 : the length of the unselected text in the lines of the selection
    # index = any other value : the line length from the character postition in the string
    def line_length(line = -1)
      send_message(:LINELENGTH, line.to_i)
    end

    def line_scroll(horizontal: 0, vertical: 0)
      send_message(:LINESCROLL, horizontal, vertical)
    end

    def pos_from_char(index = 0)
      result = send_message(:POSFROMCHAR, index)
      {horizontal: loword(result), vertical: hiword(result)}
    end

    def replace_sel(text, can_undo = true)
      text = (text + ?\0).to_w.unpack('S*') # add \0 character
      FFI::MemoryPointer.new(:uint16, text.size) do |txt|
        txt.write_array_of_uint16(text)
        send_message(:REPLACESEL, can_undo ? 1 : 0, txt.address)
      end
    end

    def scroll(action)
      loword(send_message(:SCROLL, User32::ScrollBarCommands[action.upcase]))
    end

    def scroll_caret
      send_message(:SCROLLCARET)
    end

    def set_limit_text(limit)
      send_message(:SETLIMITTEXT, limit)
    end

    def set_margins(margin, left: 0, right: 0)
      margin = case margin
                 when :left  then User32::EMSetMarginFlags[:LEFTMARGIN]
                 when :right then User32::EMSetMarginFlags[:RIGHTMARGIN]
                 when :both  then User32::EMSetMarginFlags[:LEFTMARGIN] | User32::EMSetMarginFlags[:RIGHTMARGIN]
               end
      send_message(:SETMARGINS, margin, makelong(left, right))
    end

    def left_margin=(value)
      set_margins(:left, left: value)
    end

    def right_margin=(value)
      set_margins(:right, right: value)
    end

    def margins=(left, right)
      set_margins(:both, left: left, right: right)
    end

    def set_modify(value)
      send_message(:SETMODIFY, value)
    end

    def set_password_char(char)
      send_message(:SETPASSWORDCHAR, char.to_w.unpack('S').first)
    end

    def set_read_only(value)
      send_message(:SETREADONLY, value ? 1 : 0)
    end

    def set_rect(rect)
      send_message(:SETRECT, 0, rect.pointer.address)
    end

    def set_rect_np(rect)
      send_message(:SETRECTNP, 0, rect.pointer.address)
    end

    # def reset_rect
    #   set_rect(nil)
    # end

    def set_sel(first, last)
      send_message(:SETSEL, first, last)
    end

    def set_tab_stops(number_of_tabs, tab_stops)
      send_message(:SETTABSTOPS, number_of_tabs, tab_stop.pointer)
    end

    def selection=(range)
      set_sel(range.first, range.last)
    end

    def deselect
      send_message(:SETSEL, -1)
    end

    def undo
      send_message(:UNDO)
    end

    alias_method :text_limit=,        :set_limit_text
    alias_method :first_visible_line, :get_first_visible_line
    alias_method :text_limit,         :get_limit_text
    alias_method :line,               :get_line
    alias_method :line_count,         :get_line_count
    alias_method :margins,            :get_margins
    alias_method :modified?,          :get_modify
    alias_method :modify=,            :set_modify
    alias_method :password_char,      :get_password_char
    alias_method :password_char=,     :set_password_char
    alias_method :read_only=,         :set_read_only
    alias_method :rect,               :get_rect
    alias_method :selection,          :get_sel
    alias_method :selected_text,      :get_selected_text

    def command(command)
      case User32::EditNotification[command]
        when :SETFOCUS
          set_focus
          'SETFOCUS'
        when :KILLFOCUS
          kill_focus
          'KILLFOCUS'
        when :UPDATE
          en_update
          'EN_UPDATE'
        when :CHANGE
          en_change
          'EN_CHANGE'
        when :VSCROLL
          en_vscroll
          'EN_VSCROLL'
        when :HSCROLL
          en_hscroll
          'EN_HSCROLL'
        when :MAXTEXT
          en_maxtext
          'EN_MAXTEXT'
      end
    end

    private
    def create_window_style
      edit_style = [
          alignment.upcase,
          :NOHIDESEL,
          multiline    && :MULTILINE,
          autohscroll  && :AUTOHSCROLL,
          autovscroll  && :AUTOVSCROLL,
          !can_edit && :READONLY,
          is_number && :NUMBER,
          is_password && :PASSWORD,
          case letter_case
            when :normal then nil
            when :upcase, :uppercase then :UPPERCASE
            when :downcase, :lowercase then :LOWERCASE
          end
      ].select { |flag| flag } # removes falsey elements

      vertical_alignment = [:TOP, :VCENTER, :BOTTOM].map { |v| User32::ButtonStyle[v] }.reduce(0, &:|)
      edit_style.map { |v| User32::EditStyle[v] }.reduce(0, &:|) | super & ~(vertical_alignment)
    end

    def create_window_style_extended
      !can_resize && User32::WindowStyleExtended[:CLIENTEDGE] || super
    end

    def en_change
      # User32.SetWindowTextW(@hwnd, params[:value].to_w)
      text_size = User32.GetWindowTextLength(@handle) + 1
      FFI::MemoryPointer.new(:ushort, text_size) do |text|
        User32.GetWindowText(@handle, text, text_size)
        text = text.read_array_of_uint16(text_size - 1).pack('U*')
        set_value :text, text
      end
    end

    def en_maxtext
      # TODO
    end

    def en_vscroll
      call_hooks :on_vertical_scroll
    end

    def en_hscroll
      call_hooks :on_horizontal_scroll
    end

    def en_update
      #TODO
    end

    # def method_missing(m, *args)
    #   text.send(:m, *args) if String.new.respond_to?(:m)
    # end

    def send_message(message, wparam = 0, lparam = 0)
      User32.SendMessage(@handle, User32::EditMessage[message], wparam, lparam) if @handle
    end

  end

  class Window
    def add_textbox(textbox)
      raise ArgumentError unless textbox.is_a?(TextBox)
      add_control(textbox)
    end
  end
end