class MandrillService
  def initialize(template_name, variable)
    @var = variable
    @template_name = template_name
  end

  def call
    render_mandrill_template(@template_name, @var)
  end

  private
  def render_mandrill_template(template_name, var)
     MANDRILL.templates.render(template_name, [], merge_vars(var))["html"]
  end

  def merge_vars(var)
    var.map do |key , value|
      {name: key, content: value}
    end
  end
end
