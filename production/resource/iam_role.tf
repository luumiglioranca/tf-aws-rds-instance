data "aws_iam_policy_document" "main" {
  count = var.create && var.enhanced_monitoring ? 1 : 0
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "main" {
  count = var.create && var.enhanced_monitoring ? 1 : 0

  name               = "${var.db_name}-MonitoringRDSRole"
  assume_role_policy = data.aws_iam_policy_document.main.0.json

  tags = merge(
    {
      "Name" = "${format("%s", var.db_name)}-MonitoringRDSRole"
    },
    var.default_tags,
  )
}

resource "aws_iam_role_policy_attachment" "main" {
  count = var.create && var.enhanced_monitoring ? 1 : 0

  role       = aws_iam_role.main.0.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

#Random ID para identificação do snapshot (Apenas se precisar)
resource "random_id" "snapshot_identifier" {
  count = var.create ? 1 : 0

  byte_length = 4
  keepers = {
    id = var.db_name
  }
}