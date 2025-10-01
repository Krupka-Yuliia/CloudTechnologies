output "user_id" {
  description = "Object ID of created user"
  value       = azuread_user.az104_user1.object_id
}

output "user_principal_name" {
  description = "User Principal Name"
  value       = azuread_user.az104_user1.user_principal_name
}

output "group_id" {
  description = "Object ID of the group"
  value       = azuread_group.it_lab_admins.object_id
}

output "group_name" {
  description = "Group name"
  value       = azuread_group.it_lab_admins.display_name
}

output "guest_user_id" {
  description = "Object ID of invited guest"
  value       = var.guest_email != "" ? azuread_invitation.guest_user[0].user_id : null
}

output "guest_email" {
  description = "Email of invited guest"
  value       = var.guest_email != "" ? var.guest_email : "Guest was not invited"
}

output "guest_status" {
  description = "Invite status"
  value       = var.guest_email != "" ? "Invitation has been sent to ${var.guest_email}" : "Guest was not created"
}