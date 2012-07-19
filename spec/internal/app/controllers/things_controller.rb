class ThingsController < ApplicationController
  respond_to :html
  before_filter :find_resource

  def index
    @resources = Thing.all
    respond_with(@resources)
  end

  def show
    respond_with(@resource)
  end

  def new
    @resource = Thing.new
    respond_with(@resource)
  end

  def edit
    respond_with(@resource)
  end

  def create
    @resource = Thing.new
    @resource.assign_attributes(params[:thing])
    flash.notice = "Thing created" if @resource.save
    respond_with(@resource)
  end

  def update
    @resource.assign_attributes(params[:thing])
    flash.notice = "Thing updated" if @resource.save
    respond_with(@resource)
  end

  def destroy
    flash.notice = "Thing destroyed" if @resource.destroy
    respond_with(@resource)
  end

  private

  def find_resource
    if params[:id]
      @resource = Thing.all.detect { |t| t.id == params[:id].to_i }
    end
  end
end
