require 'fiddle'
module Readline
  module Ext
    unless @@loaded
      libreadline = Fiddle.dlopen(nil)

      # accept line
      accept_line = Fiddle::Function.new(
        libreadline['rl_newline'],
        [Fiddle::TYPE_INT, Fiddle::TYPE_INT],
        Fiddle::TYPE_INT
      )

      Readline.define_singleton_method(:accept_line) do
        accept_line.call(1, "\n".ord)
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

      Readline.define_singleton_method(:unbind_key) do |key|
        unbind_key.call(key.ord)
      end

      # bind key
      bind_key = Fiddle::Function.new(
        libreadline['rl_bind_key'],
        [Fiddle::TYPE_INT, Fiddle::TYPE_UINTPTR_T],
        Fiddle::TYPE_INT
      )

      Readline.define_singleton_method(:bind_key) do |key, &block|
        unbind_key.call(key.ord)
        bind_key.call(
          key.ord,
          Fiddle::Closure::BlockCaller.new(
            Fiddle::TYPE_VOID,
            [Fiddle::TYPE_VOID],
            &block
          ).to_i
        )
      end

      # bind key sequence
      bind_keyseq = Fiddle::Function.new(
        libreadline['rl_bind_keyseq'],
        [Fiddle::TYPE_UINTPTR_T, Fiddle::TYPE_UINTPTR_T],
        Fiddle::TYPE_INT
      )
      # unbind key sequence
      Readline.define_singleton_method(:unbind_keyseq) do |keyseq_ptr|
        bind_keyseq.call(
          Fiddle::Pointer[keyseq_ptr],
          null_function.to_i
        )
      end
      Readline.define_singleton_method(:bind_keyseq) do |keyseq, &block|
        unbind_keyseq(keyseq)
        bind_keyseq.call(
          Fiddle::Pointer[keyseq],
          Fiddle::Closure::BlockCaller.new(
            Fiddle::TYPE_VOID,
            [Fiddle::TYPE_VOID],
            &block
          ).to_i
        )
      end

      # helpers
      Readline.define_singleton_method(:replace_buffer) do |new_contents|
        Readline.delete_text
        Readline.point = 0
        Readline.insert_text input
        Readline.redisplay
      end
      @@loaded = true
    end
  end
  extend Ext
end
