class Ckeditor::Picture < Ckeditor::Asset
  attr_accessor :data

  has_attached_file :data,
                    url: :url_for_images,
                    path: :path_for_images,
                    styles: { content: '600>', thumb: '118x100#' }

  validates_attachment_presence :data
  validates_attachment_size :data, in: 0..2.megabytes
  validates_attachment_content_type :data, content_type: /\Aimage/

  belongs_to :company
  validates_presence_of :company

  @@category = nil
  @@company_id = nil

  def self.images_category=(category)
    @@category = category
  end

  def self.for_company_id=(company_id)
    @@company_id = company_id
  end

  def save
    self.company_id = @@company_id if @@company_id
    super
  end

  def self.all
    @@company_id ? super.where(company_id: @@company_id) : super
  end

  private
  def url_for_images
    return '/ckeditor_assets/pictures/:id/:style_:basename.:extension' unless @@category
    "/ckeditor_assets/pictures/#{@@category}/:hashed_path/:id/:style_:basename.:extension"
  end

  def path_for_images
    ':rails_root/public' + url_for_images
  end
end
