$(document).on("ready turbolinks:load", function() {

  //email format check
  $.validator.addMethod("emailExt", function (value, element, param) {
    if (this.optional(element)) {
        return true;
    }
    return value.match(/^[a-zA-Z0-9_\.%\+\-]+@[a-zA-Z0-9\.\-]+\.[a-zA-Z]{2,}$/);
  }, 'Please enter a valid email address.');

  $("#frm_admin_organization").validate({
      rules: {
        "organization[org_name]": {
          required: true,
        },
        "organization[no_of_students]": {
          required: true,
          range: [1, 9999]
        },
        "professor[email]": {
          emailExt: true,
          required: true,
          remote: "/admin/organizations/check_email?for_admin=true&id=" + $('#professor_id').val()
        },
        "professor[password]": {
          required: true,
        },
        "student[email]": {
          emailExt: true,
          required: true,
          remote: "/admin/organizations/check_email?for_admin=false&id=" + $('#student_id').val()
        },
        "student[password]": {
          required: true,
        }
      },
      messages: {
        "organization[org_name]": {
          required: "Please enter an Organization name."
        },
        "organization[no_of_students]": {
          required: "Please enter no  of students."
        },
        "professor[email]": {
          required: "Please enter professor email.",
          remote: "Email already exist."
        },
        "professor[password]": {
          required: "Please enter professor password."
        },
        "student[email]": {
          required: "Please enter student email.",
          remote: "Email already exist."
        },
        "student[password]": {
          required: "Please enter student password."
        }
      }
  });

  $("#organization_no_of_students").bind('keypress', function(event){
    if (event.which < 48 || event.which > 57) {
        event.preventDefault();
    }
  });

  $(".toggle-password").click(function() {

    $(this).toggleClass("fa-eye fa-eye-slash");
    var input = $($(this).attr("toggle"));
    if (input.attr("type") == "password") {
      input.attr("type", "text");
    } else {
      input.attr("type", "password");
    }
  });

});
