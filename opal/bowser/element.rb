require 'bowser/event_target'
require 'bowser/file_list'
require 'bowser/delegate_native'

module Bowser
  class Element
    include EventTarget
    include DelegateNative

    def initialize native
      @native = native
    end

    def inner_dom= node
      clear
      append node
    end

    def inner_html
      `#@native.innerHTML`
    end

    def inner_html= html
      `#@native.innerHTML = html`
    end

    def children
      elements = []

      %x{
        var children = #@native.children;
        for(var i = 0; i < children.length; i++) {
          elements[i] = #{Element.new(`children[i]`)};
        }
      }

      elements
    end

    def empty?
      `#@native.children.length === 0`
    end

    def clear
      if %w(input textarea).include? type
        `#@native.value = null`
      else
        children.each do |child|
          remove_child child
        end
      end

      self
    end

    def remove_child child
      `#@native.removeChild(child.native ? child.native : child)`
    end

    def type
      `#@native.nodeName`.downcase
    end

    def append node
      `#@native.appendChild(node.native ? node.native : node)`
      self
    end

    # Form input methods
    def checked?
      `!!#@native.checked`
    end

    # Convenience for when you only need a single file
    def file
      files.first
    end

    def files
      FileList.new(`#@native.files`)
    end

    def ==(other)
      `#@native === #{other.to_n}`
    end

    def []= attribute, value
      `#@native.setAttribute(#{attribute}, #{value})`
    end

    def [] attribute
      `#@native.getAttribute(#{attribute})`
    end

    def to_n
      @native
    end
  end
end
