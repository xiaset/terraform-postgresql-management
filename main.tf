provider "postgresql" {
  host            = var.postgres_host
  port            = var.postgres_port
  database        = var.postgres_db
  username        = var.postgres_user
  password        = var.postgres_password
  sslmode         = var.ssl_mode
  connect_timeout = var.connect_timeout
  superuser       = var.superuser
}

# Define PostgreSQL databases with dynamic attributes using lookup
resource "postgresql_database" "db" {
  for_each = var.databases

  name              = each.key
  owner             = lookup(each.value, "owner", null)
  template          = lookup(each.value, "template", "template0")
  lc_collate        = lookup(each.value, "lc_collate", "C")
  connection_limit  = lookup(each.value, "connection_limit", -1)
  allow_connections = lookup(each.value, "allow_connections", true)
  is_template       = lookup(each.value, "is_template", false)
  encoding          = lookup(each.value, "encoding", "UTF8")

  depends_on = [postgresql_role.role]
}

resource "postgresql_role" "role" {
  for_each = var.roles

  name                      = each.key
  superuser                 = lookup(each.value, "superuser", false)
  create_database           = lookup(each.value, "create_database", false)
  create_role               = lookup(each.value, "create_role", false)
  inherit                   = lookup(each.value, "inherit", true)
  login                     = lookup(each.value, "login", false)
  replication               = lookup(each.value, "replication", false)
  bypass_row_level_security = lookup(each.value, "bypass_row_level_security", false)
  connection_limit          = lookup(each.value, "connection_limit", -1)
  encrypted_password        = lookup(each.value, "encrypted_password", true)
  password                  = lookup(each.value, "password", null)
  roles                     = contains(keys(each.value), "roles") ? each.value["roles"] : []
  search_path               = contains(keys(each.value), "search_path") ? each.value["search_path"] : []
  valid_until               = lookup(each.value, "valid_until", "infinity")
  skip_drop_role            = lookup(each.value, "skip_drop_role", false)
  skip_reassign_owned       = lookup(each.value, "skip_reassign_owned", false)
  statement_timeout         = lookup(each.value, "statement_timeout", 0)
  assume_role               = lookup(each.value, "assume_role", null)
}

resource "postgresql_grant" "grant" {
  for_each = { for idx, grant in var.grants : idx => grant }

  database          = each.value.database
  role              = each.value.role
  schema            = each.value.schema
  object_type       = each.value.object_type
  objects           = each.value.objects
  columns           = each.value.object_type == "column" ? each.value.columns : []
  privileges        = each.value.privileges
  with_grant_option = lookup(each.value, "with_grant_option", false)

  depends_on = [postgresql_role.role, postgresql_database.db, postgresql_schema.schema]
}

resource "postgresql_grant_role" "grant_role" {
  for_each = { for idx, grant in var.role_grants : idx => grant }

  role              = each.value.role
  grant_role        = each.value.grant_role
  with_admin_option = lookup(each.value, "with_admin_option", false)

  depends_on = [postgresql_role.role]
}

resource "postgresql_default_privileges" "default_priv" {
  for_each = { for idx, priv in var.default_privileges : idx => priv }

  role        = each.value.role
  database    = each.value.database
  schema      = each.value.schema
  owner       = each.value.owner
  object_type = each.value.object_type
  privileges  = each.value.privileges

  depends_on = [postgresql_role.role, postgresql_database.db, postgresql_schema.schema]
}

resource "postgresql_schema" "schema" {
  for_each = { for idx, schema in var.schemas : idx => schema }

  name          = each.value.name
  database      = lookup(each.value, "database", null)
  owner         = lookup(each.value, "owner", null)
  if_not_exists = lookup(each.value, "if_not_exists", true)
  drop_cascade  = lookup(each.value, "drop_cascade", false)

  dynamic "policy" {
    for_each = each.value.policies
    content {
      create            = lookup(policy.value, "create", false)
      create_with_grant = lookup(policy.value, "create_with_grant", false)
      role              = policy.value.role  # Assuming 'role' is a required attribute
      usage             = lookup(policy.value, "usage", false)
      usage_with_grant  = lookup(policy.value, "usage_with_grant", false)
    }
  }

  depends_on = [postgresql_role.role, postgresql_database.db]
}

