# Demo controller for testing base UI layout
class DemoController < ApplicationController
  # Demo page to showcase base UI components
  def index
    flash.now[:notice] = "Đây là thông báo thành công mẫu!" if params[:flash] == "success"
    flash.now[:alert] = "Đây là thông báo lỗi mẫu!" if params[:flash] == "error"
    flash.now[:warning] = "Đây là thông báo cảnh báo mẫu!" if params[:flash] == "warning"
  end
end
