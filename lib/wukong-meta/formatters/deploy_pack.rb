require_relative("../formatter")

module Wukong
  module Meta
    class DeployPackFormatter < Formatter

      def objects
        @objects ||= [Wukong::Deploy.settings[:deploy_pack] || {}]
      end

      def retrieve whatever
        objects.first
      end

      def column_names
        [:name, :title, :git_url]
      end

      def as_hash deploy_pack
        {
          _id:   deploy_pack[:name],
          _type: "deploy_packs",
          updated_at: Time.now.iso8601,
          name:  deploy_pack[:name],
          title: deploy_pack[:title],
          git_url: git_url,
          description: deploy_pack[:description],
        }
      end

      def git_url
        
      end

      def display_text deploy_pack
        f.display_line "#{heading('APP:')} #{deploy_pack[:name]}"
        f.display_line "#{heading('TITLE:')} #{deploy_pack[:title]}"
        display_description(deploy_pack[:description])
      end

    end
  end
end
