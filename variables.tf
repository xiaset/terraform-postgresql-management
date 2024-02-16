variable "postgres_host" {
  description = "The host address for the PostgreSQL server."
  type        = string
}

variable "postgres_port" {
  description = "The port for the PostgreSQL server."
  type        = number
  default     = 5432
}

variable "postgres_db" {
  description = "The default database to connect to."
  type        = string
}

variable "postgres_user" {
  description = "Username for the server connection."
  type        = string
}

variable "postgres_password" {
  description = "Password for the server connection."
  type        = string
}

variable "ssl_mode" {
  description = "SSL mode for the connection."
  type        = string
  default     = "require"
}

variable "superuser" {
  description = "Should be set to false if the user to connect is not a PostgreSQL superuser (as is the case in AWS RDS or GCP SQL)"
  type        = bool
  default     = true
}

variable "connect_timeout" {
  description = "Maximum wait for connection, in seconds."
  type        = number
  default     = 15
}

variable "databases" {
  description = "Map of database configurations."
  type        = map(any)
  default     = {}
}

variable "roles" {
  description = "Map of role configurations."
  type        = any
  default     = {}
}

variable "grants" {
  description = "List of grant configurations."
  type = list(object({
    database          = string
    role              = string
    schema            = string
    object_type       = string
    objects           = list(string)
    columns           = list(string)
    privileges        = list(string)
    with_grant_option = bool
  }))
  default = []
}

variable "role_grants" {
  description = "List of role grant configurations."
  type = list(object({
    role              = string
    grant_role        = string
    with_admin_option = bool
  }))
  default = []
}

variable "default_privileges" {
  description = "List of default privilege configurations."
  type = list(object({
    role        = string
    database    = string
    schema      = string
    owner       = string
    object_type = string
    privileges  = list(string)
  }))
  default = []
}

variable "schemas" {
  description = "List of PostgreSQL schema configurations."
  type = any
}

