variable "resource_group_name" {
  default = "myTFResourceGroup"
}

# Prefix for naming convention
variable "prefix" {
  description = "A short prefix to include in all resource names for uniqueness and consistency."
  type        = string
  default     = "tf"
}

# Whether to use regex-based sanitization (requires Terraform version that supports regexreplace)
variable "use_regex_sanitizer" {
  description = "Enable regexreplace sanitization to strip all non-alphanumeric characters from the prefix."
  type        = bool
  default     = true
}