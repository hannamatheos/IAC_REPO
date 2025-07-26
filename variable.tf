variable "owner" {
  description = "The base name to use for resources (e.g., hanna)."
  type        = string
  default     = "hanna"
}

variable "vpc_name" {
  description = "The name of the VPC to reference."
  type        = string
  default     = "hanna-vpc" # Defaulting to hanna-vpc as requested
}