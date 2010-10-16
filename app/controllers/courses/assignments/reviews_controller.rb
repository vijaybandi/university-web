class Courses::Assignments::ReviewsController < Courses::Assignments::Base
  before_filter :find_submission
  before_filter :find_review, :only => [:show, :edit, :update, :comment]
  before_filter :students_and_instructors_only
  
  def index
    @reviews = @assignment.reviews.order("updated_at DESC")
  end
  
  def new
    if @submission.open_review?
      redirect_to course_assignment_review_path(@assignment.course, @assignment.id, @submission.review.id)
    else
      @review = @submission.reviews.build
    end
  end
  
  def create
    @review = @submission.reviews.new(params[:assignment_review])
    
    if @review.save
      UserMailer.review_created(@review).deliver
      
      flash[:notice] = "Review submitted"
      redirect_to root_path
    else
      render :action => :new
    end
  end
  
  def show
    render :action => :edit
  end
  
  def edit
    
  end
  
  def update    
    @review.submission.update_attributes(params[:assignment_review]['assignment_submission'])
    
    @review.close!(current_user)
    
    flash[:notice] = "Review closed"
    
    redirect_to root_path
  end
  
  def comment
    @review.create_comment(params[:comment].merge(:user_id => current_user.id))
    
    redirect_to course_assignment_review_path(@assignment.course, @assignment, @review)
  end
  
  private
  
  def find_submission
    @submission = @assignment.submission_for(current_user)
  end
  
  def find_review
    @review = Assignment::Review.find(params[:id])
  end
  
  def students_and_instructors_only
    if !@assignment.course.students.include?(current_user) and
       !@assignment.course.instructors.include?(current_user)
      
       flash[:notice] = "You are not enrolled in this course!"
       redirect_to courses_path 
    end
  end
end
