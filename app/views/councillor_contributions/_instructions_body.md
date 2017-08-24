You should be able to find the information we need from the <%= @authority.full_name %> website.
Find their list of elected "councillors" or "aldermen" and for each one add their full name and email into the form below.

* **Full Name** should be just their given names, first name first. Leave out titles and other information.  For example, if you find "Lord Mayor Alderman Dr Sue Robbins Chen OAM" just enter "Sue Robbins Chen".
* **Email** should be the email address for contacting that individual councillor.

Add all the councillors by clicking the "Add another councillor" button.

If you have any questions or can't find all the information you need, please let us know, we're here to help. Contact us by email at <%= mail_to "contact@planningalerts.org.au", "contact@planningalerts.org.au." %>

<small>
<%=
  link_to(
    "Improve these instructions.",
    "https://github.com/openaustralia/planningalerts/blob/master/app/views/councillor_contributions/_instructions_body.html.haml",
    title: "You submit changes to these instructions on GitHub with a free GitHub account.",
    target: "_blank"
  )
%>
</small>
