
require_relative 'model'


class Visitor
    def visit(subject)
        method_name = "visit_#{subject.class}"
        send(method_name, subject)
    end
end


class GetContent < Visitor

    def initialize(search_path)
        if(search_path == "")
            @folders = [""]
        else
            @folders = search_path.split('/') #.reverse!()
        end
        @path = []
        @result = nil
    end

    def visit_ElemImage(subject)
    end

    def visit_ElemFolder(subject)
        @path.push(subject.name)

        subject.element_list.each{|elem|
            elem.accept(self)
        }

        if @folders == @path
            @result = subject.element_list
        end
        @path.pop()
    end

    def get_result()
        return @result
    end
end


class GetImage < Visitor
    def initialize(image_path)

        @image = nil
        if(image_path == "")
            @folders = [""]
        else
            @folders = image_path.split('/') #.reverse!()
            @image = @folders.pop()
        end
        @path = []
        @result = nil
        @right_place = false
    end

    def visit_ElemImage(subject)
        temp_image = ElemImage.new(@image)

        @right_place = @folders == @path
        if @right_place and subject == temp_image
            @result = subject
        end
    end

    def visit_ElemFolder(subject)
        @path.push(subject.name)

        subject.element_list.each{|elem| elem.accept(self) }

        @path.pop()
    end

    def get_result()
        return @result
    end
end


class SetContent < Visitor
    def initialize(path, elem)
        if(path == "")
            @folders = [""]
        else
            @folders = path.split('/')
        end
        @element = elem
        @path = []
        @result = false
    end

    def visit_ElemImage(subject)
    end

    def visit_ElemFolder(subject)
        @path.push(subject.name)

        subject.element_list.each{|elem|
            elem.accept(self)
        }

        if @folders == @path
            subject.add_element(@element)
            @result = true
        end

        @path.pop()
    end

    def get_result()
        return @result
    end
end


class ManageTag < Visitor

    attr_reader :succeed

    # Set an operation for tags
    # Params:
    # +image_path+:: path of image to be modified /vacations/sol.png
    # +operation+:: could be 'add' or 'delete'
    def initialize(image_path, tag, operation)

        @image = nil

        if(image_path == "")
            @folders = [""]
        else
            @folders = image_path.split('/')
            @image = @folders.pop()
        end

        @tag = tag
        if operation != "add" and operation != "delete"
            raise(UnknownTagOperation, "unknown tag operation: '#{operation}'")
        end
        @operation = operation

        @path = []
        @right_place = false
        @succeed = false
    end

    def visit_ElemImage(subject)
        temp_image = ElemImage.new(@image)

        @right_place = @folders == @path

        if @right_place and subject == temp_image
            tag_method = "#{@operation}_tag"
            subject.send(tag_method, @tag)
            @succeed = true
        end
    end

    def visit_ElemFolder(subject)
        @path.push(subject.name)

        subject.element_list.each{|elem|
            elem.accept(self)
        }

        @path.pop()
    end
end


class GetShortImages < Visitor

    # Get a list of images class, this class retrieve the name and path
    # of all images for the given path
    def initialize(image_path)

        if(image_path == "")
            @folders = [""]
        else
            @folders = image_path.split('/') #.reverse!()
        end
        @result = Array.new
        @path = Array.new
    end

    def visit_ElemImage(subject)
        belongs_to_path = @folders <=> @path
        if belongs_to_path <= 0
            @result.push( {
                "name" => subject.name,
                "path" => @path.rotate(1).join('/')
                } )
        end
    end

    def visit_ElemFolder(subject)
        @path.push(subject.name)

        subject.element_list.each{|elem| elem.accept(self) }

        @path.pop()
    end

    def get_result()
        return @result
    end
end


class GetMatchImages < Visitor

    # Get a list of images class, this class retrieve the name and path
    # of all images for the given path
    def initialize(folder_path, text)

        if(folder_path == "")
            @folders = [""]
        else
            @folders = folder_path.split('/') #.reverse!()
        end
        @text = text
        @result = Array.new
        @path = Array.new
    end

    def visit_ElemImage(subject)
        belongs_to_path = @folders <=> @path
        if belongs_to_path <= 0 and subject.name.include?(@text)
            @result.push( {
                "name" => subject.name,
                "path" => @path.rotate(1).join('/'),
                "preview" => subject.preview
                } )
        end
    end

    def visit_ElemFolder(subject)
        @path.push(subject.name)
        subject.element_list.each{|elem| elem.accept(self) }
        @path.pop()
    end

    def get_result()
        return @result
    end
end


def normalize_return_data(element, message_nil = "is nil")

    if element.nil?()
        return_message = {}
        return_message[:status] = "error"
        return_message[:message] = message_nil
        return return_message
    end

    if element.kind_of?(Array)
        return convert_list(element, 'tags', 'preview')
    else
        return convert_to_hash(element, 'data')
    end
end

def convert_list(element_list, *fields)
    return_message = []
    element_list.each{|elem| 
        item = convert_to_hash(elem, *fields)
        return_message.push(item)
      }
    return return_message
end

def convert_to_hash(element, *attributes)
    item = {}
    item['name'] = element.name
    item['type'] = element.class.type_name
    if item['type'] == 'image'
        attributes.each{|attrib|
            item[attrib] = element.send(attrib)
        }
    end

    return item
end
