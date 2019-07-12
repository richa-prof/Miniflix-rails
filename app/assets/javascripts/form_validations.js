$(document).on('turbolinks:load', function() {

  $("#frm_admin_organization").validate({
      rules: {
        "organization[org_name]": {
          required: true,
        },
        "organization[no_of_students]": {
          required: true,
        },
        "professor[email]": {
          required: true,
          email: true,
          remote: "/admin/organizations/check_email?for_admin=true"
        },
        "professor[password]": {
          required: true,
        },
        "student[email]": {
          required: true,
          email: true,
          remote: "/admin/organizations/check_email?for_admin=false"
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
