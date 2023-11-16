provider "google-beta" {
  credentials = file("./tf-sa.json")
  project = "MY-PROJECT"
}

resource "google_container_cluster" "cluster-east" {
  provider = google-beta
  name               = "cluster-east"
  location           = "us-east4"
  enable_autopilot = true
}

resource "google_gke_hub_membership" "cluster-east-fleet" {
  provider = google-beta
  membership_id = google_container_cluster.cluster-east.name
  endpoint {
    gke_cluster {
     resource_link = "//container.googleapis.com/${google_container_cluster.cluster-east.id}"
    }
  }
  depends_on = [google_container_cluster.cluster-east]
}

resource "google_container_cluster" "cluster-west" {
  provider = google-beta
  name               = "cluster-west"
  location           = "us-west4"
  enable_autopilot = true
}

resource "google_gke_hub_membership" "cluster-west-fleet" {
  provider = google-beta
  membership_id = google_container_cluster.cluster-west.name
  endpoint {
    gke_cluster {
     resource_link = "//container.googleapis.com/${google_container_cluster.cluster-west.id}"
    }
  }
  depends_on = [google_container_cluster.cluster-west]
}

resource "google_gke_hub_feature" "feature-cs" {
  name = "configmanagement"
  location = "global"
  provider = google-beta
  fleetDefaultMemberConfig {
    configmanagement {
      version = "1.16.0"
      config_sync {
        git {
          sync_repo = "https://github.com/some-repo/e2m-mcg-asm"
          sync_branch = "main"
          secret_type = "none"
          sync_wait_secs = 15
          policy_dir = "./config-dir"
        }
        source_format = "hierarchy"
      }
    }
  }
  #depends_on = [google_gke_hub_membership.tf-another-cluster-fleet]
  depends_on = [google_gke_hub_membership.cluster-east-fleet, google_gke_hub_membership.cluster-west-fleet]
}
resource "google_gke_hub_feature" "feature-sm" {
  name = "servicemesh"
  location = "global"
  fleetDefaultMemberConfig {
    mesh {
      management = "MANAGEMENT_AUTOMATIC"
    }
  }
  #depends_on = [google_gke_hub_membership.tf-another-cluster-fleet]
  depends_on = [google_gke_hub_membership.cluster-east-fleet, google_gke_hub_membership.cluster-west-fleet]
}

resource "google_gke_hub_feature" "feature-mci" {
  name = "multiclusteringress"
  location = "global"
  spec {
    multiclusteringress {
      config_membership = google_gke_hub_membership.cluster-east-fleet.id
    }
  }
  depends_on = [google_gke_hub_membership.cluster-east-fleet, google_gke_hub_membership.cluster-west-fleet]
}

resource "google_gke_hub_feature" "feature-mcs" {
  name = "multiclusterservicediscovery"
  location = "global"
  depends_on = [google_gke_hub_membership.cluster-east-fleet, google_gke_hub_membership.cluster-west-fleet]
}
