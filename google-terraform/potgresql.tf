#
# CloudSQL Postgres Database
#

# Create a random string to be used in database instance name
# SQL instance name cannot be reused after deletion for 1 week

resource "random_id" "db_instance_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "graph" {
  database_version       = var.postgresql_version
  name                   = "${var.project_id}-psql-${random_id.db_instance_name_suffix.hex}"
  deletion_protection    = false
  settings {
    activation_policy      = "ALWAYS"
    availability_type      = "REGIONAL"
    disk_autoresize        = true
    disk_size              = 256
    disk_type              = "PD_SSD"
    tier                   = var.postgresql_database_tier
    backup_configuration {
      binary_log_enabled = false
      enabled            = true
      start_time         = "02:00"
    }
    database_flags {
      name  = "log_temp_files"
      value = "-1"
    }
    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.vpc.id
      authorized_networks {
        name  = "Management public IP"
        value = local.management-external-cidr
      }
      authorized_networks {
        name  = "Other Mgmt CIDR IP Block defined in vars file"
        value = var.gke_management_ips
      }
    }
  }
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "graph" {
  name     = var.postgresql_dbname_indexer
  instance = google_sql_database_instance.graph.name
  depends_on = [ google_sql_database_instance.graph ]
}

resource "google_sql_database" "indexer-service" {
  name     = var.postgresql_dbname_service
  instance = google_sql_database_instance.graph.name
  depends_on = [ google_sql_database_instance.graph ]
}

resource "google_sql_user" "graph" {
  name     = var.postgresql_admin_user
  instance = google_sql_database_instance.graph.name
  password = var.postgresql_admin_password
  depends_on = [ google_sql_database_instance.graph ]
}