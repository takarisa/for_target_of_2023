/*
---------------------------------
AWS EC2 Backup Settings
---------------------------------
*/

# Backup Plan
resource "aws_backup_plan" "xxxxx_backup_plan" {
  name = "xxxxx-backup-plan"

  rule {
    rule_name         = "xxxxx_backup_rule"
    target_vault_name = aws_backup_vault.xxxxx_backup_vault.name
    ## UTC表記 JSTだと+9して3時
    schedule = "cron(0 18 * * ? *)"
    ## 2日後に削除
    lifecycle {
      delete_after = 2
    }
  }
}
# Backup Vault
resource "aws_backup_vault" "xxxxx_backup_vault" {
  name = "xxxxx-backup-vault"
  tags = {
    Name = "xxxxx-backup-vault"
  }
}

# Backup Selection
resource "aws_backup_selection" "xxxxx_backup_selection" {
  iam_role_arn = aws_iam_role.xxxxx_backup_role.arn
  name         = "xxxxx-backup-selection"
  plan_id      = aws_backup_plan.xxxxx_backup_plan.id
  selection_tag {
    ## タグがbackup=enabledのものをバックアップ対象に
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "enabled"
  }
}

/*
---------------------------------
AWS RDS Backup Settings
---------------------------------
*/

# Backup Plan
resource "aws_backup_plan" "xxxxx_rds_backup_plan" {
  name = "xxxxx-rds-backup-plan"

  rule {
    rule_name         = "xxxxx_rds_backup_rule"
    target_vault_name = aws_backup_vault.xxxxx_rds_backup_vault.name
    ## UTC表記 JSTだと+9して3時
    schedule = "cron(0 18 * * ? *)"
    ## 7日後に削除
    lifecycle {
      delete_after = 7
    }
  }
}
# Backup Vault
resource "aws_backup_vault" "xxxxx_rds_backup_vault" {
  name = "xxxxx-rds-backup-vault"
  tags = {
    Name = "xxxxx-rds-backup-vault"
  }
}

# Backup Selection
resource "aws_backup_selection" "xxxxx_rds_backup_selection" {
  iam_role_arn = aws_iam_role.xxxxx_backup_role.arn
  name         = "xxxxx-rds-backup-selection"
  plan_id      = aws_backup_plan.xxxxx_rds_backup_plan.id
  selection_tag {
    ## タグが RDS_backup=enabled のものをバックアップ対象に
    type  = "STRINGEQUALS"
    key   = "RDS_backup"
    value = "enabled"
  }
}

/*
---------------------------------
AWS S3 Backup Settings
---------------------------------
*/

# Backup Plan
resource "aws_backup_plan" "xxxxx_s3_backup_plan" {
  name = "xxxxx-s3-backup-plan"

  rule {
    rule_name         = "xxxxx_s3_backup_rule"
    target_vault_name = aws_backup_vault.xxxxx_s3_backup_vault.name
    ## UTC表記 JSTだと+9して3時
    schedule = "cron(0 18 * * ? *)"
    ## 7日後に削除
    lifecycle {
      delete_after = 7
    }
  }
}
# Backup Vault
resource "aws_backup_vault" "xxxxx_s3_backup_vault" {
  name = "xxxxx-s3-backup-vault"
  tags = {
    Name = "xxxxx-s3-backup-vault"
  }
}

# Backup Selection
resource "aws_backup_selection" "xxxxx_s3_backup_selection" {
  iam_role_arn = aws_iam_role.xxxxx_backup_role.arn
  name         = "xxxxx-s3-backup-selection"
  plan_id      = aws_backup_plan.xxxxx_s3_backup_plan.id
  selection_tag {
    ## タグが s3_backup=enabled のものをバックアップ対象に
    type  = "STRINGEQUALS"
    key   = "S3_backup"
    value = "enabled"
  }
}
