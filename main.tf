
# main.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  # Cluster Configuration
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true
  
  # Node Groups Configuration
  eks_managed_node_groups = {
    main = {
      # Node group configuration
      name = "main-node-group"

      # Instance configuration
      instance_types = var.instance_types
      capacity_type  = var.capacity_type

      # Scaling configuration
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      # Disk configuration
      disk_size = 50

      # Labels
      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      # Tags
      tags = merge(
        var.tags,
        {
          "k8s.io/cluster-autoscaler/enabled" = "true"
          "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        }
      )
    }
  }

  # Cluster Addons
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  # Tags
  tags = var.tags
}
