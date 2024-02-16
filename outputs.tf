# Output for PostgreSQL Roles
output "roles" {
  description = "Details of the created PostgreSQL roles."
  value = {
    for role in postgresql_role.role : role.name => {
      name                      = role.name
      superuser                 = role.superuser
      create_database           = role.create_database
      create_role               = role.create_role
      inherit                   = role.inherit
      login                     = role.login
      replication               = role.replication
      bypass_row_level_security = role.bypass_row_level_security
      connection_limit          = role.connection_limit
      encrypted_password        = role.encrypted_password
      #password              = role.password
      roles               = role.roles
      search_path         = role.search_path
      valid_until         = role.valid_until
      skip_drop_role      = role.skip_drop_role
      skip_reassign_owned = role.skip_reassign_owned
      statement_timeout   = role.statement_timeout
      assume_role         = role.assume_role
    }
  }
}

# Output for PostgreSQL Databases
output "databases" {
  description = "Details of the created PostgreSQL databases."
  value = {
    for db in postgresql_database.db : db.name => {
      name              = db.name
      owner             = db.owner
      template          = db.template
      lc_collate        = db.lc_collate
      connection_limit  = db.connection_limit
      allow_connections = db.allow_connections
      is_template       = db.is_template
      encoding          = db.encoding
    }
  }
}

output "created_grants" {
  description = "Details of the PostgreSQL grants created."
  value = {
    for grant in postgresql_grant.grant : grant.id => {
      database          = grant.database
      role              = grant.role
      schema            = grant.schema
      object_type       = grant.object_type
      objects           = grant.objects
      columns           = grant.columns
      privileges        = grant.privileges
      with_grant_option = grant.with_grant_option
    }
  }
}

output "created_role_grants" {
  description = "Details of the PostgreSQL role memberships created."
  value = {
    for grant_role in postgresql_grant_role.grant_role : grant_role.id => {
      role              = grant_role.role
      grant_role        = grant_role.grant_role
      with_admin_option = grant_role.with_admin_option
    }
  }
}

output "created_default_privileges" {
  description = "Details of the PostgreSQL default privileges created."
  value = {
    for priv in postgresql_default_privileges.default_priv : priv.id => {
      role        = priv.role
      database    = priv.database
      schema      = priv.schema
      owner       = priv.owner
      object_type = priv.object_type
      privileges  = priv.privileges
    }
  }
}

output "created_schemas" {
  description = "Details of the PostgreSQL schemas created."
  value = {
    for sch in postgresql_schema.schema : sch.name => {
      name          = sch.name
      database      = sch.database
      owner         = sch.owner
      if_not_exists = sch.if_not_exists
      drop_cascade  = sch.drop_cascade
      policies      = [
        for p in sch.policy : {
          create            = p.create
          create_with_grant = p.create_with_grant
          role              = p.role
          usage             = p.usage
          usage_with_grant  = p.usage_with_grant
        }
      ]
    }
  }
}

