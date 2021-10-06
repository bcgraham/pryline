require 'fiddle'
require 'fiddle/import'
require 'forwardable'
require 'readline'
module Pryline
  unless defined?(@@loaded) && @@loaded
    HISTORY = Readline::HISTORY
    extend SingleForwardable
    def_delegators :Readline,
      :basic_quote_characters,
      :basic_quote_characters=,
      :basic_word_break_characters,
      :basic_word_break_characters=,
      :completer_quote_characters,
      :completer_quote_characters=,
      :completer_word_break_characters,
      :completer_word_break_characters=,
      :completion_append_character,
      :completion_append_character=,
      :completion_case_fold,
      :completion_case_fold=,
      :completion_proc,
      :completion_proc=,
      :completion_quote_character,
      :delete_text,
      :emacs_editing_mode,
      :emacs_editing_mode?,
      :filename_quote_characters,
      :filename_quote_characters=,
      :get_screen_size,
      :input=,
      :insert_text,
      :line_buffer,
      :output=,
      :point,
      :point=,
      :pre_input_hook,
      :pre_input_hook=,
      :quoting_detection_proc,
      :quoting_detection_proc=,
      :readline,
      :redisplay,
      :refresh_line,
      :set_screen_size,
      :special_prefixes,
      :special_prefixes=,
      :vi_editing_mode,
      :vi_editing_mode?

    libreadline = Fiddle.dlopen(nil)

    BLOCK_CALLERS = {}

    # paren blink timeout
    set_paren_blink_timeout = Fiddle::Function.new(
      libreadline['rl_set_paren_blink_timeout'],
      [Fiddle::TYPE_INT],
      Fiddle::TYPE_INT
    )

    Pryline.define_singleton_method(:set_paren_blink_timeout) do |usec|
      set_paren_blink_timeout.call(usec)
    end

    # accept line
    accept_line = Fiddle::Function.new(
      libreadline['rl_newline'],
      [Fiddle::TYPE_INT, Fiddle::TYPE_INT],
      Fiddle::TYPE_INT
    )

    Pryline.define_singleton_method(:accept_line) do
      accept_line.call(1, "\n".ord)
    end

    # previous line
    previous_line = Fiddle::Function.new(
      libreadline['rl_previous_screen_line'],
      [Fiddle::TYPE_INT, Fiddle::TYPE_INT],
      Fiddle::TYPE_INT
    )
    Pryline.define_singleton_method(:previous_line) do
      previous_line.call(1, "f".ord)
    end

    # next line
    next_line = Fiddle::Function.new(
      libreadline['rl_next_screen_line'],
      [Fiddle::TYPE_INT, Fiddle::TYPE_INT],
      Fiddle::TYPE_INT
    )
    Pryline.define_singleton_method(:next_line) do
      next_line.call(1, "f".ord)
    end

    # next history
    next_history = Fiddle::Function.new(
      libreadline['rl_get_next_history'],
      [Fiddle::TYPE_INT, Fiddle::TYPE_INT],
      Fiddle::TYPE_INT
    )
    Pryline.define_singleton_method(:next_history) do
      next_history.call(1, "f".ord)
    end

    # previous history
    previous_history = Fiddle::Function.new(
      libreadline['rl_get_previous_history'],
      [Fiddle::TYPE_INT, Fiddle::TYPE_INT],
      Fiddle::TYPE_INT
    )
    Pryline.define_singleton_method(:previous_history) do
      previous_history.call(1, "f".ord)
    end

    where_history = Fiddle::Function.new(
      libreadline['where_history'],
      [Fiddle::TYPE_VOID],
      Fiddle::TYPE_INT
    )
    Pryline.define_singleton_method(:where_history) do
      where_history.call(nil)
    end

    # null function
    null_function = Fiddle::Function.new(
      libreadline['_rl_null_function'],
      [Fiddle::TYPE_INT, Fiddle::TYPE_INT],
      Fiddle::TYPE_INT
    )

    # unbind key
    unbind_key = Fiddle::Function.new(
      libreadline['rl_unbind_key'],
      [Fiddle::TYPE_INT],
      Fiddle::TYPE_INT
    )

    Pryline.define_singleton_method(:unbind_key) do |key|
      unbind_key.call(key.ord)
    end

    # bind key
    bind_key = Fiddle::Function.new(
      libreadline['rl_bind_key'],
      [Fiddle::TYPE_INT, Fiddle::TYPE_UINTPTR_T],
      Fiddle::TYPE_INT
    )

    Pryline.define_singleton_method(:bind_key) do |key, &block|
      unbind_key.call(key.ord)
      BLOCK_CALLERS[key] = Fiddle::Closure::BlockCaller.new(
        Fiddle::TYPE_VOID,
        [Fiddle::TYPE_VOID],
        &block
      )
      bind_key.call(
        key.ord,
        BLOCK_CALLERS[key].to_i
      )
    end

    # bind key sequence
    bind_keyseq = Fiddle::Function.new(
      libreadline['rl_bind_keyseq'],
      [Fiddle::TYPE_UINTPTR_T, Fiddle::TYPE_UINTPTR_T],
      Fiddle::TYPE_INT
    )
    # unbind key sequence
    Pryline.define_singleton_method(:unbind_keyseq) do |keyseq_ptr|
      bind_keyseq.call(
        Fiddle::Pointer[keyseq_ptr],
        null_function.to_i
      )
    end
    Pryline.define_singleton_method(:bind_keyseq) do |keyseq, &block|
      unbind_keyseq(keyseq)
      BLOCK_CALLERS[keyseq] = Fiddle::Closure::BlockCaller.new(
        Fiddle::TYPE_VOID,
        [Fiddle::TYPE_VOID],
        &block
      )
      bind_keyseq.call(
        Fiddle::Pointer[keyseq],
        BLOCK_CALLERS[keyseq].to_i
      )
    end

    # message

    save_prompt = Fiddle::Function.new(libreadline['rl_save_prompt'], [Fiddle::TYPE_VOID], Fiddle::TYPE_INT)
    Pryline.define_singleton_method(:save_prompt) do
      save_prompt.call(nil)
    end
    set_message = Fiddle::Function.new(libreadline['rl_message'], [Fiddle::TYPE_UINTPTR_T], Fiddle::TYPE_INT)
    Pryline.define_singleton_method(:set_message) do |message|
      buffer, point = Pryline.line_buffer, Pryline.point
      Pryline.delete_text
      Pryline.point = 0
      Pryline.redisplay
      Pryline.save_prompt
      Pryline.insert_text buffer
      Pryline.point = point
      set_message.call(
        Fiddle::Pointer[message]
      )
    end

    restore_prompt = Fiddle::Function.new(libreadline['rl_restore_prompt'], [Fiddle::TYPE_VOID], Fiddle::TYPE_INT)
    Pryline.define_singleton_method(:restore_prompt) do
      restore_prompt.call(nil)
    end
    clear_message = Fiddle::Function.new(libreadline['rl_clear_message'], [Fiddle::TYPE_VOID], Fiddle::TYPE_INT)
    Pryline.define_singleton_method(:clear_message) do
      Pryline.restore_prompt
      clear_message.call(nil)
    end

    move_vert = Fiddle::Function.new(libreadline['_rl_move_vert'], [Fiddle::TYPE_INT], Fiddle::TYPE_VOID)
    Pryline.define_singleton_method(:move_vert) do |dest|
      move_vert.call(dest)
    end

    PromptLength = Fiddle::CStructBuilder.create(
      Fiddle::CStruct,
      [Fiddle::SIZEOF_INT],
      %w(value)
    ).new(Fiddle::Pointer.new(libreadline.sym('rl_visible_prompt_length')).to_i)
    Pryline.define_singleton_method(:prompt_width) { PromptLength.value }

    LastCPos = Fiddle::CStructBuilder.create(
      Fiddle::CStruct,
      [Fiddle::SIZEOF_INT],
      %w(value)
    ).new(Fiddle::Pointer.new(libreadline.sym('_rl_last_c_pos')).to_i)
    Pryline.define_singleton_method(:last_c_pos) { LastCPos.value }
    LastVPos = Fiddle::CStructBuilder.create(
      Fiddle::CStruct,
      [Fiddle::SIZEOF_INT],
      %w(value)
    ).new(Fiddle::Pointer.new(libreadline.sym('_rl_last_v_pos')).to_i)
    Pryline.define_singleton_method(:last_v_pos) { LastVPos.value }
    ApplicationName = Fiddle::CStructBuilder.create(
      Fiddle::CStruct,
      [1],
      %w(rl_readline_name)
    ).new(Fiddle::Pointer.new(libreadline.sym('rl_readline_name')).to_i)
    Pryline.define_singleton_method(:application_name) { ApplicationName.rl_readline_name.to_s }
    Pryline.define_singleton_method(:application_name=) do |name|
      ApplicationName.rl_readline_name = Fiddle::Pointer[name]
    end

    # helpers
    Pryline.define_singleton_method(:replace_buffer) do |new_contents|
      Pryline.delete_text
      Pryline.point = 0
      Pryline.insert_text new_contents
      Pryline.redisplay
    end
    @@loaded = true
  end
end
