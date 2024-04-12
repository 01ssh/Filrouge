
resource "aws_kms_key" "clusterDB_kms_key" {
  description             = "Definition de la cle kms pour la db cluster aurora"
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "clusterDB_kms_alias" {
  name          = "alias/wordpressDBcluster"
  target_key_id = aws_kms_key.clusterDB_kms_key.id
}
