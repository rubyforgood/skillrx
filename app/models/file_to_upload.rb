# data structure for language-specific file uploads:
# id: technical identifier for the file
# name: human-readable name for the file, used to store file and then send it
# content: the content of the file, which is generated by the XML or text generator
# path: the path where the file is going to be uploaded
class FileToUpload < Data.define(:id, :name, :content, :path)
end
