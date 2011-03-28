module RedmineCustom
  module BoardsPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        # Change preconditions for Boards controller. 
        skip_before_filter :find_project
        skip_before_filter :authorize
        before_filter :find_project, :except => [:index, :show]
        before_filter :find_optional_project, :only => [:index]
        before_filter :authorize, :except => [:index]
        
        alias_method_chain :index, :optional_project
        alias_method_chain :find_board_if_available, :optional_project
      end
    end

    module InstanceMethods
      # Allow boards/index without current project selected
      def index_with_optional_project
        if @project
          index_without_optional_project
        else
          @boards = Board.all
        end
      end

      # Do not require current project to be selected to find a borad
      def find_board_if_available_with_optional_project
        if @project
          find_board_if_available_without_optional_project
        else
          @project = @board.project if @board = Board.find(params[:id]) if params[:id]
        end
        
        rescue ActiveRecord::RecordNotFound
          render_404
      end
    end
  end
end
