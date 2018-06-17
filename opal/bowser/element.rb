require 'bowser/event_target'
require 'bowser/delegate_native'

module Bowser
  autoload :FileList, 'bowser/file_list'
  autoload :Iterable, 'bowser/iterable'

  # Wrap a native DOM element
  class Element
    include EventTarget
    include DelegateNative

    @tags = Hash.new(self)

    def self.element *tags, &block
      tags.each do |tag|
        @tags
          .fetch(tag) { @tags[tag] = const_set(tag.capitalize, Class.new(self)) }
          .class_exec(&block)
      end
    end

    def self.new(native)
      element = @tags[`(#{native}.tagName || '')`.downcase].allocate
      element.initialize native
      element
    end

    # @param native [JS] The native DOM element to wrap
    def initialize native
      @native = native
    end

    # Replace all child elements with the given element
    #
    # @param element [Bowser::Element] The Bowser element with which to replace
    #   this element's contents
    def inner_dom= element
      clear
      append element
    end

    # The contents of this element as an HTML string
    #
    # @return [String] the HTML representation of this element's contents
    def inner_html
      `#@native.innerHTML`
    end

    # Use the supplied HTML string to replace this element's contents
    #
    # @param html [String] the HTML with which to replace this elements contents
    def inner_html= html
      `#@native.innerHTML = html`
    end

    # This element's direct child elements
    #
    # @return [Array<Bowser::Element>] list of this element's children
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

    # Determine whether this element has any contents
    #
    # @return [Boolean] true if the element has no children, false otherwise
    def empty?
      `#@native.children.length === 0`
    end

    # Remove all contents from this element. After this call, `empty?` will
    # return `true`.
    #
    # @return [Bowser::Element] self
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

    # Remove the specified child element
    #
    # @param child [Bowser::Element] the child element to remove
    def remove_child child
      `#@native.removeChild(child['native'] ? child['native'] : child)`
    end

    # This element's type. For example: "div", "span", "p"
    #
    # @return [String] the HTML tag name for this element
    def type
      `#@native.nodeName`.downcase
    end

    # Append the specified element as a child element
    #
    # @param element [Bowser::Element, JS] the element to insert
    def append node
      `#@native.appendChild(node['native'] ? node['native'] : node)`
      self
    end

    # Methods for <input /> elements

    # A checkbox's checked status
    #
    # @return [Boolean] true if the checkbox is checked, false otherwise
    def checked?
      `!!#@native.checked`
    end

    # Get the currently selected file for this input. This is only useful for
    # file inputs without the `multiple` property set.
    #
    # @return [Bowser::File] the file selected by the user
    def file
      files.first
    end

    # Get the currently selected files for this input. This is only useful for
    # file inputs with the `multiple` property set.
    #
    # @return [Bowser::FileList] the currently selected files for this input
    def files
      FileList.new(`#@native.files`)
    end

    # Determine whether this is the same element
    #
    # @return [boolean] true if the element is the same, false otherwise
    def ==(other)
      `#@native === #{other.to_n}`
    end

    # Set the specified attribute to the specified value
    def []= attribute, value
      `#@native.setAttribute(#{attribute}, #{value})`
    end

    # Return the specified attribute
    #
    # @return [String] the value for the specified attribute
    def [] attribute
      `#@native.getAttribute(#{attribute})`
    end

    def query_selector selector
      result = super

      Element.new(result) if result
    end

    def query_selector_all selector
      Iterable.new(super).map { |element| Element.new(element) }
    end

    # The native representation of this element.
    #
    # @return [JS] the native element wrapped by this object.
    def to_n
      @native
    end
  end
end
