module API
  # Adds an endpoint that customizes the update action on nested works
  class GenericWorksController < ApplicationController
    before_action :my_load_and_authorize_resource, only: [:update, :destroy, :show, :add_parent, :remove_parent]
    before_action :my_load_parent_resource, only: [:add_parent]
    attr_reader :work, :parent

    def create
      head :created, location: sufia.api_item_path(actor.create_work_from_item)
    end

    def update
      head :no_content
    end

    def destroy
      head :no_content
    end

    def show
      head :no_content
    end

    def add_parent
      if @work.in_works_ids.include?(@parent.id)
        return render plain: "These works already have an association.", status: :bad_request
      end

      actor.update(new_attributes)

      return render json: details_to_json
    rescue StandardError
      return render plain: "Server error", status: :server_error
    end

    def remove_parent
      old_in_works_ids = @work.in_works_ids
      delete_parent = old_in_works_ids.delete(params[:parent_id])

      # TODO: if delete_parent.nil? then error?
      unless delete_parent.nil?
        updated_attributes = @work.attributes.merge(in_works_ids: old_in_works_ids).except!("id")
        actor.update(updated_attributes)
      end
      head :no_content
    end

    private

      def new_attributes
        old_in_works_ids = @work.in_works_ids
        old_in_works_ids.push(@parent.id)
        new_in_works_ids = old_in_works_ids.uniq
        @work.attributes.merge(in_works_ids: new_in_works_ids).except!("id")
      end

      def details_to_json
        {
          parent: {
            title: @parent.title,
            path: polymorphic_path(@parent),
            id: @parent.id
          },
          child: {
            title: @work.title,
            path: polymorphic_path(@work),
            id: @work.id
          }
        }
      end

      def my_load_parent_resource
        @parent = GenericWork.find(params[:parent_id])

      rescue ActiveFedora::ObjectNotFoundError
        return render plain: "Parent '#{params[:parent_id]}' not found.", status: :not_found
      end

      def my_load_and_authorize_resource
        @work = GenericWork.find(params[:id])

        unless user.can? :edit, @work
          return render plain: "#{user} lacks access to #{@work}", status: :unauthorized
        end

      rescue ActiveFedora::ObjectNotFoundError
        return render plain: "id '#{params[:id]}' not found", status: :not_found
      end

      def user
        User.find_by_email(@work.depositor)
      end

      def actor
        CurationConcerns::CurationConcern.actor(@work, user)
      end
  end
end
